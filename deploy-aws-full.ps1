# Definitive Deployment Script for Insomnia Butler (AWS ECS + RDS)
# This handles building, pushing, database creation (PG 18.1), and task launch.

param(
    [Parameter(Mandatory=$true)]
    [string]$GeminiApiKey
)

$ErrorActionPreference = "SilentlyContinue"
$PROJECT = "insomniabutler"
$REGION = "us-east-1"
$env:AWS_PAGER = "" # Fix 'cat' issue on Windows

function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }

function Set-ContentUtf8NoBom {
    param($Path, $Content)
    $Utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Resolve-Path .).Path + "\" + $Path, $Content, $Utf8NoBom)
}

Write-Info "=========================================="
Write-Info "  Full AWS Deployment (PG 18.1 + ECS)"
Write-Info "=========================================="

# 1. Get AWS Account ID
$ACCOUNT_ID = (aws sts get-caller-identity --query 'Account' --output text).Trim()
$ECR_URI = "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-server"

# 2. Build & Push Image
Write-Info "Step 1: Building and Pushing Docker Image..."
if (Test-Path "insomniabutler_server") {
    Set-Location "insomniabutler_server"
    docker build -t "$PROJECT-server" .
    Set-Location ".."
} else {
    Write-Warning "Directory 'insomniabutler_server' not found. Skipping build."
}

$LOGIN_PASSWORD = (aws ecr get-login-password --region $REGION)
$LOGIN_PASSWORD | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# Create repo if not exists
try { aws ecr create-repository --repository-name "$PROJECT-server" --region $REGION --no-cli-pager } catch {}

docker tag "${PROJECT}-server:latest" "${ECR_URI}:latest"
docker push "${ECR_URI}:latest"

# 3. Create RDS Instance (PostgreSQL 18.1)
Write-Info "Step 2: Ensuring RDS Instance (PG 18.1) exists..."
$StateFile = "aws-deployment-state.json"
if (Test-Path $StateFile) {
    $StateObj = Get-Content $StateFile | ConvertFrom-Json
    $DB_PASSWORD = $StateObj.dbPassword
}

if (-not $DB_PASSWORD) {
    # Generate a strong password if not found in state
    $DB_PASSWORD = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})
}

try {
    aws rds create-db-instance `
        --db-instance-identifier "$PROJECT-db" `
        --db-instance-class db.t3.micro `
        --engine postgres `
        --engine-version 18.1 `
        --master-username postgres `
        --master-user-password $DB_PASSWORD `
        --allocated-storage 20 `
        --publicly-accessible `
        --db-name $PROJECT `
        --region $REGION `
        --no-deletion-protection `
        --no-cli-pager
    Write-Info "RDS creation initiated. This takes ~10 minutes."
} catch {
    if ($_ -like "*DBInstanceAlreadyExists*") {
        Write-Info "RDS Instance already exists."
        # Ensure it's version 18.1
        Write-Info "Checking version..."
        $currentVersion = aws rds describe-db-instances --db-instance-identifier "$PROJECT-db" --region $REGION --query "DBInstances[0].EngineVersion" --output text
        if ($currentVersion -ne "18.1") {
            Write-Warning "Current version is $currentVersion. Upgrading to 18.1..."
            aws rds modify-db-instance --db-instance-identifier "$PROJECT-db" --engine-version 18.1 --allow-major-version-upgrade --apply-immediately --region $REGION --no-cli-pager
        }
    } else {
        throw $_
    }
}

# Wait for RDS to have an endpoint if it just started or exists
Write-Info "Fetching RDS Endpoint..."
$rdsEndpoint = ""
while (-not $rdsEndpoint -or $rdsEndpoint -eq "None") {
    $status = aws rds describe-db-instances --db-instance-identifier "$PROJECT-db" --region $REGION --query "DBInstances[0].DBInstanceStatus" --output text
    if ($status) { $status = $status.Trim() }
    
    $rdsEndpoint = aws rds describe-db-instances --db-instance-identifier "$PROJECT-db" --region $REGION --query "DBInstances[0].Endpoint.Address" --output text
    if ($rdsEndpoint) { $rdsEndpoint = $rdsEndpoint.Trim() }
    
    if ($rdsEndpoint -eq "None" -or -not $rdsEndpoint) {
        Write-Info "Waiting for RDS endpoint (Current Status: $status)..."
        Start-Sleep -Seconds 30
    }
}
Write-Success "RDS Endpoint: $rdsEndpoint"

# 4. ECS Setup
Write-Info "Step 3: Setting up ECS Fargate..."

# Create Cluster
try { aws ecs create-cluster --cluster-name "$PROJECT-cluster" --region $REGION --no-cli-pager } catch {}

# Log Group
Write-Info "Ensuring CloudWatch Log Group exists..."
try {
    aws logs create-log-group --log-group-name "/ecs/$PROJECT" --region $REGION --no-cli-pager
} catch {}

# IAM Role for ECS
Write-Info "Checking ecsTaskExecutionRole..."
$trustPolicy = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
'@
$trustPath = Join-Path (Get-Location).Path "ecs-trust-policy.json"
Set-ContentUtf8NoBom "ecs-trust-policy.json" $trustPolicy

$roleName = (aws iam list-roles --query "Roles[?RoleName=='ecsTaskExecutionRole'].RoleName" --output text --region $REGION).Trim()
if ($roleName -ne "ecsTaskExecutionRole") {
    Write-Info "Creating ecsTaskExecutionRole..."
    aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document "file://$trustPath" --region $REGION --no-cli-pager
} else {
    Write-Info "Updating ecsTaskExecutionRole trust policy..."
    aws iam update-assume-role-policy --role-name ecsTaskExecutionRole --policy-document "file://$trustPath" --region $REGION --no-cli-pager
}

# Always ensure policy is attached
Write-Info "Ensuring policy attached to ecsTaskExecutionRole..."
aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy --region $REGION

# Wait for IAM propagation
Write-Info "Waiting for IAM propagation (30s)..."
Start-Sleep -Seconds 30

# Register Task Definition
$taskDefContent = @"
{
  "family": "$PROJECT-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
  "containerDefinitions": [{
    "name": "$PROJECT-server",
    "image": "${ECR_URI}:latest",
    "portMappings": [{"containerPort": 8080, "protocol": "tcp"}],
    "environment": [
      {"name": "runmode", "value": "production"},
      {"name": "serverid", "value": "default"},
      {"name": "DB_HOST", "value": "$rdsEndpoint"},
      {"name": "DB_PORT", "value": "5432"},
      {"name": "DB_NAME", "value": "$PROJECT"},
      {"name": "DB_USER", "value": "postgres"},
      {"name": "DB_PASSWORD", "value": "$DB_PASSWORD"},
      {"name": "GEMINI_API_KEY", "value": "$GeminiApiKey"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/$PROJECT",
        "awslogs-region": "$REGION",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
"@

Set-ContentUtf8NoBom "task-def-final.json" $taskDefContent
aws ecs register-task-definition --cli-input-json file://task-def-final.json --region $REGION --no-cli-pager
if ($LASTEXITCODE -ne 0) { Write-Host "CRITICAL: Failed to register task definition" -ForegroundColor Red; exit 1 }

# 5. Networking logic
$vpcId = (aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --region $REGION --query "Vpcs[0].VpcId" --output text).Trim()
$subnetsOutput = aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcId" --region $REGION --query "Subnets[0:2].SubnetId" --output text
$subnets = $subnetsOutput.Trim() -split '\s+'
$subnetList = $subnets -join ','

# ALB Security Group
Write-Info "Ensuring ALB Security Group..."
$albSgId = (aws ec2 describe-security-groups --filters "Name=group-name,Values=$PROJECT-alb-sg" --region $REGION --query "SecurityGroups[0].GroupId" --output text 2>$null).Trim()
if ($LASTEXITCODE -ne 0 -or $albSgId -eq "None" -or -not $albSgId) {
    $albSgId = (aws ec2 create-security-group --group-name "$PROJECT-alb-sg" --description "ALB SG for Insomnia Butler" --vpc-id $vpcId --region $REGION --query "GroupId" --output text).Trim()
    aws ec2 authorize-security-group-ingress --group-id $albSgId --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION --no-cli-pager
}

# ECS Security Group
Write-Info "Ensuring ECS Security Group..."
$sgId = (aws ec2 describe-security-groups --filters "Name=group-name,Values=$PROJECT-sg" --region $REGION --query "SecurityGroups[0].GroupId" --output text 2>$null).Trim()
if ($LASTEXITCODE -ne 0 -or $sgId -eq "None" -or -not $sgId) {
    $sgId = (aws ec2 create-security-group --group-name "$PROJECT-sg" --description "SG for Insomnia Butler" --vpc-id $vpcId --region $REGION --query "GroupId" --output text).Trim()
}
# Allow ALB to access ECS on port 8080
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 8080 --source-group $albSgId --region $REGION --no-cli-pager 2>$null

# RDS Security Group ingress for ECS
Write-Info "Allowing ECS to access RDS..."
$rdsSgId = (aws rds describe-db-instances --db-instance-identifier "$PROJECT-db" --region $REGION --query "DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId" --output text 2>$null).Trim()
if ($LASTEXITCODE -eq 0 -and $rdsSgId -ne "None") {
    aws ec2 authorize-security-group-ingress --group-id $rdsSgId --protocol tcp --port 5432 --source-group $sgId --region $REGION --no-cli-pager 2>$null
}

# ALB Setup
Write-Info "Step 4: Setting up Load Balancer..."
$albArn = (aws elbv2 describe-load-balancers --names "$PROJECT-alb" --region $REGION --query "LoadBalancers[0].LoadBalancerArn" --output text 2>$null).Trim()
if (-not $albArn -or $albArn -eq "None") {
    $albArn = (aws elbv2 create-load-balancer --name "$PROJECT-alb" --subnets $subnets --security-groups $albSgId --region $REGION --query "LoadBalancers[0].LoadBalancerArn" --output text).Trim()
}
$albDns = (aws elbv2 describe-load-balancers --load-balancer-arns $albArn --region $REGION --query "LoadBalancers[0].DNSName" --output text).Trim()

# Target Group
$tgArn = (aws elbv2 describe-target-groups --names "$PROJECT-tg" --region $REGION --query "TargetGroups[0].TargetGroupArn" --output text 2>$null).Trim()
if (-not $tgArn -or $tgArn -eq "None") {
    $tgArn = (aws elbv2 create-target-group --name "$PROJECT-tg" --protocol HTTP --port 8080 --vpc-id $vpcId --target-type ip --region $REGION --query "TargetGroups[0].TargetGroupArn" --output text).Trim()
    # Health check settings (Serverpod health check is /)
    aws elbv2 modify-target-group --target-group-arn $tgArn --health-check-path "/" --health-check-interval-seconds 30 --region $REGION --no-cli-pager
}

# Listener
$listenerArn = (aws elbv2 describe-listeners --load-balancer-arn $albArn --region $REGION --query "Listeners[0].ListenerArn" --output text 2>$null).Trim()
if (-not $listenerArn -or $listenerArn -eq "None") {
    aws elbv2 create-listener --load-balancer-arn $albArn --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$tgArn --region $REGION --no-cli-pager
}

# 6. Service Update/Create
Write-Info "Step 5: Launching Service..."
# Note: Changing load balancer config usually requires replacing the service, but we'll try update first for task def changes.
$updateResult = aws ecs update-service --cluster "$PROJECT-cluster" --service "$PROJECT-service" --task-definition "$PROJECT-task" --region $REGION --no-cli-pager 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Info "Service not found. Creating new service..."
    aws ecs create-service `
        --cluster "$PROJECT-cluster" `
        --service-name "$PROJECT-service" `
        --task-definition "$PROJECT-task" `
        --desired-count 1 `
        --launch-type FARGATE `
        --network-configuration "awsvpcConfiguration={subnets=[$($subnets -join ',')],securityGroups=[$sgId],assignPublicIp=ENABLED}" `
        --load-balancers "targetGroupArn=$tgArn,containerName=$PROJECT-server,containerPort=8080" `
        --region $REGION `
        --no-cli-pager
} else {
    # If update succeeded, we must check if it's attached to the LB. If not, we might need to recreate it.
    # For simplicity in this script, we assume if it exists, it's correct.
    # If users want to attach an existing no-LB service to an LB, they usually must delete and recreate.
    Write-Info "Service updated."
}

Write-Info "Service launch initiated."
Write-Success "Full deployment script completed."
Write-Success "ALB DNS Name: $albDns"

# Save state
$state = @{
    region = $REGION
    accountId = $ACCOUNT_ID
    ecrRepositoryUri = $ECR_URI
    dbPassword = $DB_PASSWORD
    geminiApiKey = $GeminiApiKey
    rdsEndpoint = $rdsEndpoint
    vpcId = $vpcId
    subnets = $subnets
    securityGroupId = $sgId
    albDns = $albDns
    albArn = $albArn
}
$stateJson = $state | ConvertTo-Json
Set-ContentUtf8NoBom "aws-deployment-state.json" $stateJson
.\run-migrations.ps1



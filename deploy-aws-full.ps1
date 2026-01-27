# Definitive Deployment Script for Insomnia Butler (AWS ECS + RDS)
# This handles networking, database creation (PG 18.1), building, and task launch.

param(
    [Parameter(Mandatory = $true)]
    [string]$GeminiApiKey
)

$ErrorActionPreference = "Continue"
$PROJECT = "insomniabutler"
$REGION = "us-east-1"
$env:AWS_PAGER = "" # Fix 'cat' issue on Windows

function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }

function Set-ContentUtf8NoBom {
    param($Path, $Content)
    $Utf8NoBom = New-Object System.Text.UTF8Encoding $false
    # Ensure directory exists if path contains it
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
    [System.IO.File]::WriteAllText((Resolve-Path .).Path + "\" + $Path, $Content, $Utf8NoBom)
}

function Get-SafeAwsOutput {
    param($command)
    $output = Invoke-Expression $command 2>$null
    if ($output -and $output -ne "None") {
        return $output.Trim()
    }
    return ""
}

Write-Info "=========================================="
Write-Info "  Full AWS Deployment (PG 18.1 + ECS)"
Write-Info "=========================================="

if (-not $GeminiApiKey) {
    Write-Host "ERROR: GeminiApiKey parameter is required." -ForegroundColor Red
    exit 1
}

# 1. Get AWS Account ID
Write-Info "Checking AWS Identity..."
$identityJson = aws sts get-caller-identity
if (-not $identityJson) { Write-Host "CRITICAL: AWS CLI not configured or no identity found." -ForegroundColor Red; exit 1 }
$identity = $identityJson | ConvertFrom-Json
$ACCOUNT_ID = $identity.Account
$ECR_URI = "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-server"

# 2. Networking Setup (VPC, Subnets, SGs)
Write-Info "Step 1: Setting up Networking and Security Groups..."
$vpcId = Get-SafeAwsOutput "aws ec2 describe-vpcs --filters `"Name=isDefault,Values=true`" --region $REGION --query `"Vpcs[0].VpcId`" --output text"
$subnetsOutput = Get-SafeAwsOutput "aws ec2 describe-subnets --filters `"Name=vpc-id,Values=$vpcId`" --region $REGION --query `"Subnets[0:2].SubnetId`" --output text"
$subnets = $subnetsOutput -split '\s+'
if (-not $subnets[0]) { Write-Host "CRITICAL: No subnets found in VPC $vpcId" -ForegroundColor Red; exit 1 }
$subnetList = $subnets -join ','


# ALB Security Group
$albSgId = Get-SafeAwsOutput "aws ec2 describe-security-groups --filters `"Name=group-name,Values=$PROJECT-alb-sg`" --region $REGION --query `"SecurityGroups[0].GroupId`" --output text"
if (-not $albSgId) {
    $albSgId = Get-SafeAwsOutput "aws ec2 create-security-group --group-name `"$PROJECT-alb-sg`" --description `"ALB SG for Insomnia Butler`" --vpc-id $vpcId --region $REGION --query `"GroupId`" --output text"
    aws ec2 authorize-security-group-ingress --group-id $albSgId --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION --no-cli-pager
}

# ECS Security Group
$sgId = Get-SafeAwsOutput "aws ec2 describe-security-groups --filters `"Name=group-name,Values=$PROJECT-sg`" --region $REGION --query `"SecurityGroups[0].GroupId`" --output text"
if (-not $sgId) {
    $sgId = Get-SafeAwsOutput "aws ec2 create-security-group --group-name `"$PROJECT-sg`" --description `"SG for Insomnia Butler`" --vpc-id $vpcId --region $REGION --query `"GroupId`" --output text"
}
if (-not $sgId) { Write-Error "Failed to retrieve or create ECS Security Group."; exit 1 }

# Allow ALB to access ECS on port 8080
if ($albSgId) {
    aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 8080 --source-group $albSgId --region $REGION --no-cli-pager 2>$null
}


# 3. Create/Ensure RDS Instance (PostgreSQL 18.1)
Write-Info "Step 2: Ensuring RDS Instance (PG 18.1) is ready..."
$StateFile = "aws-deployment-state.json"
$DB_PASSWORD = ""
if (Test-Path $StateFile) {
    try {
        $StateObj = Get-Content $StateFile | ConvertFrom-Json
        $DB_PASSWORD = $StateObj.dbPassword
    }
    catch {}
}

if (-not $DB_PASSWORD) {
    $DB_PASSWORD = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 20 | % { [char]$_ })
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
}
catch {
    if ($_ -like "*DBInstanceAlreadyExists*") {
        Write-Info "RDS Instance already exists. Forcing password sync..."
        aws rds modify-db-instance --db-instance-identifier "$PROJECT-db" --master-user-password $DB_PASSWORD --apply-immediately --region $REGION --no-cli-pager
    }
    else {
        throw $_
    }
}

# Wait for RDS Endpoint
Write-Info "Fetching RDS Endpoint..."
$rdsEndpoint = ""
while (-not $rdsEndpoint) {
    $status = Get-SafeAwsOutput "aws rds describe-db-instances --db-instance-identifier `"$PROJECT-db`" --region $REGION --query `"DBInstances[0].DBInstanceStatus`" --output text"
    $rdsEndpoint = Get-SafeAwsOutput "aws rds describe-db-instances --db-instance-identifier `"$PROJECT-db`" --region $REGION --query `"DBInstances[0].Endpoint.Address`" --output text"
    
    if (-not $rdsEndpoint) {
        Write-Info "Waiting for RDS endpoint (Current Status: $status)..."
        Start-Sleep -Seconds 30
    }
}
Write-Success "RDS Endpoint: $rdsEndpoint"

# Allow ECS SG to access RDS SG
$rdsSgId = Get-SafeAwsOutput "aws rds describe-db-instances --db-instance-identifier `"$PROJECT-db`" --region $REGION --query `"DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId`" --output text"
if ($rdsSgId) {
    aws ec2 authorize-security-group-ingress --group-id $rdsSgId --protocol tcp --port 5432 --source-group $sgId --region $REGION --no-cli-pager 2>$null
}

# 4. ALB Setup
Write-Info "Step 3: Setting up Load Balancer..."
$albArn = Get-SafeAwsOutput "aws elbv2 describe-load-balancers --names `"$PROJECT-alb`" --region $REGION --query `"LoadBalancers[0].LoadBalancerArn`" --output text"
if (-not $albArn) {
    $albArn = Get-SafeAwsOutput "aws elbv2 create-load-balancer --name `"$PROJECT-alb`" --subnets $subnets --security-groups $albSgId --region $REGION --query `"LoadBalancers[0].LoadBalancerArn`" --output text"
}
if (-not $albArn) { Write-Error "Failed to retrieve or create Load Balancer ARN."; exit 1 }

$albDns = Get-SafeAwsOutput "aws elbv2 describe-load-balancers --load-balancer-arns $albArn --region $REGION --query `"LoadBalancers[0].DNSName`" --output text"


$tgArn = Get-SafeAwsOutput "aws elbv2 describe-target-groups --names `"$PROJECT-tg`" --region $REGION --query `"TargetGroups[0].TargetGroupArn`" --output text"
if (-not $tgArn) {
    $tgArn = Get-SafeAwsOutput "aws elbv2 create-target-group --name `"$PROJECT-tg`" --protocol HTTP --port 8080 --vpc-id $vpcId --target-type ip --region $REGION --query `"TargetGroups[0].TargetGroupArn`" --output text"
    
    if ($tgArn) {
        aws elbv2 modify-target-group --target-group-arn $tgArn --health-check-path "/" --health-check-interval-seconds 30 --region $REGION --no-cli-pager
    }
}
if (-not $tgArn) { Write-Error "Failed to retrieve or create Target Group ARN."; exit 1 }


$listenerArn = Get-SafeAwsOutput "aws elbv2 describe-listeners --load-balancer-arn $albArn --region $REGION --query `"Listeners[0].ListenerArn`" --output text"
if (-not $listenerArn) {
    # Fix: Correct syntax for create-listener (no space after comma in DefaultActions)
    aws elbv2 create-listener --load-balancer-arn $albArn --protocol HTTP --port 80 --default-actions "Type=forward,TargetGroupArn=$tgArn" --region $REGION --no-cli-pager
}


# 5. Build & Push Image
Write-Info "Step 4: Building and Pushing Docker Image..."
$state = @{
    region           = $REGION
    accountId        = $ACCOUNT_ID
    ecrRepositoryUri = $ECR_URI
    dbPassword       = $DB_PASSWORD
    geminiApiKey     = $GeminiApiKey
    rdsEndpoint      = $rdsEndpoint
    vpcId            = $vpcId
    subnets          = $subnets
    securityGroupId  = $sgId
    albDns           = $albDns
}
Set-ContentUtf8NoBom "aws-deployment-state.json" ($state | ConvertTo-Json)

if (Test-Path "insomniabutler_server") {
    Set-Location "insomniabutler_server"
    Write-Info "Generating Serverpod code..."
    serverpod generate
    docker build -t "$PROJECT-server" .
    Set-Location ".."
}

$LOGIN_PASSWORD = (aws ecr get-login-password --region $REGION)
$LOGIN_PASSWORD | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
try { aws ecr create-repository --repository-name "$PROJECT-server" --region $REGION --no-cli-pager } catch {}
docker tag "${PROJECT}-server:latest" "${ECR_URI}:latest"
docker push "${ECR_URI}:latest"

# 6. ECS Launch
Write-Info "Step 5: Launching ECS Fargate Service..."
try { aws ecs create-cluster --cluster-name "$PROJECT-cluster" --region $REGION --no-cli-pager } catch {}
try { aws logs create-log-group --log-group-name "/ecs/$PROJECT" --region $REGION --no-cli-pager } catch {}

# IAM Roles
$trustPolicy = @'
{
  "Version": "2012-10-17",
  "Statement": [{"Effect": "Allow", "Principal": {"Service": "ecs-tasks.amazonaws.com"}, "Action": "sts:AssumeRole"}]
}
'@
Set-ContentUtf8NoBom "ecs-trust-policy.json" $trustPolicy
$trustPath = (Resolve-Path "ecs-trust-policy.json").Path

$existingRole = Get-SafeAwsOutput "aws iam get-role --role-name ecsTaskExecutionRole --query `"Role.RoleName`" --output text"
if (-not $existingRole) {
    aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document "file://$trustPath" --region $REGION --no-cli-pager
    aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy --region $REGION
    Write-Info "Waiting for IAM propagation (30s)..."
    Start-Sleep -Seconds 30
}

# Register Task Def
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

# Service Update/Create
$updateResult = aws ecs update-service --cluster "$PROJECT-cluster" --service "$PROJECT-service" --task-definition "$PROJECT-task" --region $REGION --no-cli-pager 2>$null
if ($LASTEXITCODE -ne 0) {
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
}

Write-Success "`nInfrastructure deployment completed successfully!"
Write-Success "ALB DNS Name: $albDns"
Write-Host "`nNEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Wait 2-3 minutes for the ECS service to become healthy."
Write-Host "2. Run '.\run-migrations.ps1' to setup the database tables and sync the Flutter client."
Write-Host "3. Start your Flutter app!"

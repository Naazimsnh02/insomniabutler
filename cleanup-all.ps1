# Simple Robust Cleanup Script
$ErrorActionPreference = "SilentlyContinue"
$region = "us-east-1"
$env:AWS_PAGER = "" # Fix 'cat' issue on Windows

Write-Host "--- ECS ---" -ForegroundColor Yellow
$tasks = aws ecs list-tasks --cluster insomniabutler-cluster --region $region --query "taskArns" --output text
if ($tasks -and $tasks -ne "None") {
    foreach ($task in $tasks -split '\s+') {
        if ($task) { 
            Write-Host "Stopping task $task..."
            aws ecs stop-task --cluster insomniabutler-cluster --task $task --region $region 
        }
    }
}

$services = aws ecs list-services --cluster insomniabutler-cluster --region $region --query "serviceArns" --output text
if ($services -and $services -ne "None") {
    foreach ($svc in $services -split '\s+') {
        if ($svc) {
            Write-Host "Deleting service $svc..."
            aws ecs delete-service --cluster insomniabutler-cluster --service $svc --force --region $region
        }
    }
}

# Listener & ALB Cleanup
Write-Host "--- ALB ---" -ForegroundColor Yellow
$projectAlbArn = (aws elbv2 describe-load-balancers --names "insomniabutler-alb" --region $region --query "LoadBalancers[0].LoadBalancerArn" --output text 2>$null).Trim()
if ($LASTEXITCODE -eq 0 -and $projectAlbArn -ne "None") {
    $listeners = aws elbv2 describe-listeners --load-balancer-arn $projectAlbArn --region $region --query "Listeners[].ListenerArn" --output text
    if ($listeners -and $listeners -ne "None") {
        foreach ($l in $listeners -split '\s+') {
            if ($l) { aws elbv2 delete-listener --listener-arn $l --region $region }
        }
    }
    Write-Host "Deleting ALB..."
    aws elbv2 delete-load-balancer --load-balancer-arn $projectAlbArn --region $region
    # Wait for deletion
    Start-Sleep -Seconds 15
}

$tgArn = (aws elbv2 describe-target-groups --names "insomniabutler-tg" --region $region --query "TargetGroups[0].TargetGroupArn" --output text 2>$null).Trim()
if ($LASTEXITCODE -eq 0 -and $tgArn -ne "None") {
    Write-Host "Deleting Target Group..."
    aws elbv2 delete-target-group --target-group-arn $tgArn --region $region
}

Start-Sleep -Seconds 5
aws ecs delete-cluster --cluster insomniabutler-cluster --region $region

Write-Host "--- RDS ---" -ForegroundColor Yellow
aws rds delete-db-instance --db-instance-identifier insomniabutler-db --skip-final-snapshot --delete-automated-backups --region $region

Write-Host "--- ECR ---" -ForegroundColor Yellow
aws ecr delete-repository --repository-name insomniabutler-server --force --region $region

Write-Host "--- Secrets ---" -ForegroundColor Yellow
aws secretsmanager delete-secret --secret-id insomniabutler/gemini-api-key --force-delete-without-recovery --region $region
aws secretsmanager delete-secret --secret-id insomniabutler/db-password --force-delete-without-recovery --region $region

Write-Host "--- Logs ---" -ForegroundColor Yellow
aws logs delete-log-group --log-group-name /ecs/insomniabutler --region $region

Write-Host "--- IAM Roles ---" -ForegroundColor Yellow
$roles = "ecsTaskExecutionRole", "InsomniaButlerAppRunnerRole", "InsomniaButlerAppRunnerInstanceRole"
foreach ($role in $roles) {
    Write-Host "Cleaning up role $role..."
    $policies = aws iam list-attached-role-policies --role-name $role --query "AttachedPolicies[].PolicyArn" --output text
    if ($policies -and $policies -ne "None") {
        foreach ($policy in $policies -split '\s+') {
            if ($policy) { aws iam detach-role-policy --role-name $role --policy-arn $policy }
        }
    }
    $inlinePolicies = aws iam list-role-policies --role-name $role --query "PolicyNames" --output text
    if ($inlinePolicies -and $inlinePolicies -ne "None") {
        foreach ($policy in $inlinePolicies -split '\s+') {
            if ($policy) { aws iam delete-role-policy --role-name $role --policy-name $policy }
        }
    }
    aws iam delete-role --role-name $role
}

Write-Host "--- Security Groups ---" -ForegroundColor Yellow
$sgList = aws ec2 describe-security-groups --filters "Name=group-name,Values=insomniabutler-sg,insomniabutler-rds-sg,insomniabutler-alb-sg" --query "SecurityGroups[].GroupId" --output text
if ($sgList -and $sgList -ne "None") {
    foreach ($sg in $sgList -split '\s+') {
        if ($sg) { 
            Write-Host "Deleting SG $sg..."
            aws ec2 delete-security-group --group-id $sg 
        }
    }
}

Write-Host "--- Local Files ---" -ForegroundColor Yellow
$tempFiles = "aws-deployment-state.json", "task-def-final.json", "task-def.json", "task-definition.json", "service-config.json", "rds_sg.txt", "my_ip.txt", "ip.txt", "eni.txt", "task_status.json", "db_subnets.txt", "db_status.txt", "db_vpc.txt", "vpc_cidr.txt", "is_public.txt", "routes.txt", "server_logs.txt", "server_logs_new.txt", "server_logs_last.txt", "log_stream.txt", "apprunner-full-config.json", "apprunner-trust-policy.json", "apprunner-instance-trust-policy.json", "secrets-policy.json", "ecs-trust.json", "ecs-trust-policy.json"
foreach ($file in $tempFiles) {
    if (Test-Path $file) { 
        Write-Host "Removing $file..."
        Remove-Item $file -Force 
    }
}

Write-Host "Cleanup process finished." -ForegroundColor Green


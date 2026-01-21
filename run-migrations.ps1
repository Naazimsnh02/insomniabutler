# Database Migration Script for Insomnia Butler
$ErrorActionPreference = "Stop"
$env:AWS_PAGER = "" # Fix 'cat' issue on Windows

function Set-ContentUtf8NoBom {
    param($Path, $Content)
    $Utf8NoBom = New-Object System.Text.UTF8Encoding $false
    # Ensure directory exists
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
    [System.IO.File]::WriteAllText((Resolve-Path .).Path + "\" + $Path, $Content, $Utf8NoBom)
}

if (-not (Test-Path "aws-deployment-state.json")) { Write-Error "State file not found! Run deploy-aws-full.ps1 first."; exit 1 }
$state = Get-Content "aws-deployment-state.json" | ConvertFrom-Json

Write-Host "Updating local production config..." -ForegroundColor Cyan
$rdsEndpoint = $state.rdsEndpoint
if (-not $rdsEndpoint -or $rdsEndpoint -eq "None") {
    $rdsEndpoint = (aws rds describe-db-instances --db-instance-identifier "insomniabutler-db" --region $state.region --query "DBInstances[0].Endpoint.Address" --output text).Trim()
}

# Determine the public host (Prefer ALB DNS, then Task IP, then localhost)
$publicHost = $state.albDns
$publicPort = 80 # ALB listens on port 80

if (-not $publicHost) {
    Write-Host "ALB DNS not found in state, falling back to Task Public IP..." -ForegroundColor Yellow
    $taskArn = (aws ecs list-tasks --cluster "insomniabutler-cluster" --region $state.region --query "taskArns[0]" --output text).Trim()
    if ($taskArn -and $taskArn -ne "None") {
        $eniId = (aws ecs describe-tasks --cluster "insomniabutler-cluster" --tasks $taskArn --region $state.region --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text).Trim()
        $publicHost = (aws ec2 describe-network-interfaces --network-interface-ids $eniId --region $state.region --query "NetworkInterfaces[0].Association.PublicIp" --output text).Trim()
    }
    $publicPort = 8080 # Tasks listen on 8080 directly
}

if (-not $publicHost -or $publicHost -eq "None") {
    $publicHost = "localhost"
    $publicPort = 8080
}

$prodConfig = @"
# Production configuration
apiServer:
  port: 8080
  publicHost: $publicHost
  publicPort: $publicPort
  publicScheme: http

insightsServer:
  port: 8081
  publicHost: $publicHost
  publicPort: 8081
  publicScheme: http

webServer:
  port: 8082
  publicHost: $publicHost
  publicPort: 8082
  publicScheme: http

database:
  host: $rdsEndpoint
  port: 5432
  name: insomniabutler
  user: postgres
  password: $($state.dbPassword)
  requireSsl: true

redis:
  enabled: false
"@
Set-ContentUtf8NoBom "insomniabutler_server/config/production.yaml" $prodConfig

Write-Host "Updating Flutter client config..." -ForegroundColor Cyan
$flutterConfig = @{
    apiUrl = "http://$($publicHost):$publicPort"
} | ConvertTo-Json
Set-ContentUtf8NoBom "insomniabutler_flutter/assets/config.json" $flutterConfig

Write-Host "Temporarily allowing local IP to RDS..." -ForegroundColor Cyan
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content.Trim()
# Get RDS SG
$sgId = (aws rds describe-db-instances --db-instance-identifier "insomniabutler-db" --region $state.region --query "DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId" --output text).Trim()

try {
    aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 5432 --cidr "$myIp/32" --region $state.region 2>$null
}
catch {}

Write-Host "Running migrations..." -ForegroundColor Cyan
Set-Location "insomniabutler_server"
try {
    # Ensure dependencies are fetched
    dart pub get
    # Pass Gemini Key as env var just in case server initialization needs it
    $env:GEMINI_API_KEY = $state.geminiApiKey
    dart bin/main.dart --mode production --apply-migrations
    Write-Host "Migrations successful!" -ForegroundColor Green
}
catch {
    Write-Host "Migration failed: $_" -ForegroundColor Red
}
finally {
    Set-Location ".."
    aws ec2 revoke-security-group-ingress --group-id $sgId --protocol tcp --port 5432 --cidr "$myIp/32" --region $state.region 2>$null
}


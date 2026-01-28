# Deploy Script for Windows
# This script builds the Flutter web app and moves it to the server's web directory

Write-Host "Triggering Flutter Web Build..."

# 1. Store the server directory (current location)
$serverDir = Get-Location

# 2. Navigate to the Flutter project directory
$flutterDir = "../insomniabutler_flutter"
if (-not (Test-Path $flutterDir)) {
    Write-Error "Flutter directory not found at $flutterDir"
    exit 1
}
Set-Location $flutterDir

# 3. Build the Flutter web app
# We use cmd /c to ensure the flutter.bat shim is executed correctly
cmd /c "flutter build web --base-href /app/"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed."
    Set-Location $serverDir
    exit 1
}

# 4. Prepare the destination directory
$webAppDir = Join-Path $serverDir "web/app"

# Clean existing app if it exists
if (Test-Path $webAppDir) {
    Write-Host "Removing old web app..."
    Remove-Item -Recurse -Force $webAppDir
}

# 5. Move the new build
$buildWebDir = "build/web"
if (Test-Path $buildWebDir) {
    Write-Host "Moving new web app to server..."
    Move-Item $buildWebDir $webAppDir
} else {
    Write-Error "Build directory 'build/web' not found."
    Set-Location $serverDir
    exit 1
}

# 6. Return to server directory
Set-Location $serverDir
Write-Host "Build and move completed successfully."

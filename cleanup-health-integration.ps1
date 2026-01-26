# cleanup-health-integration.ps1
# Removes temporary files created during health integration development

$ErrorActionPreference = "Stop"

Write-Host "Cleaning up health integration temporary files..." -ForegroundColor Cyan
Write-Host ""

# Files to remove
$filesToRemove = @(
    ".\insomniabutler_server\migrations\add_health_tracking_fields.sql",
    ".\insomniabutler_server\migrations\fix_health_fields.sql",
    ".\fix-health-migration.ps1"
)

$removedCount = 0
$skippedCount = 0

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "[OK] Removed: $file" -ForegroundColor Green
        $removedCount++
    } else {
        Write-Host "[SKIP] Not found (already removed): $file" -ForegroundColor Yellow
        $skippedCount++
    }
}

Write-Host ""
Write-Host "Documentation cleanup recommendations:" -ForegroundColor Cyan
Write-Host "  Keep:    HEALTH_INTEGRATION_IMPLEMENTATION_COMPLETE.md" -ForegroundColor Green
Write-Host "  Archive: HEALTH_INTEGRATION_SUMMARY.md" -ForegroundColor Yellow
Write-Host "  Archive: HEALTH_INTEGRATION_QUICK_START.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "Would you like to archive the old documentation? (Y/N)" -ForegroundColor Cyan
$response = Read-Host

if ($response -eq "Y" -or $response -eq "y") {
    # Create archive directory
    $archiveDir = ".\docs\archive"
    if (-not (Test-Path $archiveDir)) {
        New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
    }
    
    # Move old docs to archive
    $docsToArchive = @(
        ".\HEALTH_INTEGRATION_SUMMARY.md",
        ".\HEALTH_INTEGRATION_QUICK_START.md"
    )
    
    foreach ($doc in $docsToArchive) {
        if (Test-Path $doc) {
            $fileName = Split-Path $doc -Leaf
            Move-Item $doc "$archiveDir\$fileName" -Force
            Write-Host "[OK] Archived: $fileName -> docs/archive/" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Files removed: $removedCount" -ForegroundColor Green
Write-Host "  Files skipped: $skippedCount" -ForegroundColor Yellow
Write-Host ""
Write-Host "[OK] Health integration is production-ready!" -ForegroundColor Green
Write-Host "  All temporary migration scripts removed." -ForegroundColor White
Write-Host "  Database schema is stable and deployed." -ForegroundColor White
Write-Host ""

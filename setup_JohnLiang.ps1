[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$workspaceRoot = $PSScriptRoot
$projectDir = Join-Path $workspaceRoot "..Project"
$avdDir = Join-Path $projectDir "avd"
$avdRepoUrl = "https://github.com/JohnLiang119/avd.git"

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   ???瑁? JohnLiang 撌乩?????啣?撱箇蔭" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 1. 蝣箔? ..Project ?桅?摮
if (-not (Test-Path $projectDir)) {
    Write-Host ">>> 撱箇?撠?銝惜?桅?: $projectDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
}

# 2. 銝? avd 撠?蝔?蝣?if (-not (Test-Path $avdDir)) {
    Write-Host ">>> 甇?敺?GitHub 銝? avd 撠? (git clone)..." -ForegroundColor Cyan
    Set-Location $projectDir
    git clone $avdRepoUrl avd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "git clone avd 憭望?嚗?瑼Ｘ蝬脰楝?????GitHub 摮?甈???
        exit 1
    }
    Write-Host "??avd 撠?銝?摰?嚗? -ForegroundColor Green
} else {
    Write-Host "?對? avd 撠?撌脣??冽 $avdDir?? -ForegroundColor Yellow
}

# 3. ?瑁??啣?靘陷??
$restoreScript = Join-Path $avdDir "restore_avd.ps1"
if (Test-Path $restoreScript) {
    Write-Host ""
    Write-Host ">>> 甇??瑁? avd ??啣??? (npm install & cap sync)..." -ForegroundColor Cyan
    Set-Location $avdDir
    powershell -ExecutionPolicy Bypass -File $restoreScript
} else {
    Write-Warning "?曆???restore_avd.ps1 ?單??
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   ?? JohnLiang 頝券?阡??潛憓歇撠梁?嚗? -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "?? 撠?頝臬?: $avdDir" -ForegroundColor Green
Write-Host "?? 撟單?憒??郊?湔嚗??瑁?: .\pull_all.ps1" -ForegroundColor Cyan
Write-Host "?? 憒???蝺刻陌嚗??瑁?: ..Project\avd\all.ps1" -ForegroundColor Cyan
Write-Host ""
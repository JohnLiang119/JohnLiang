[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$workspaceRoot = $PSScriptRoot
$projectDir = Join-Path $workspaceRoot "..Project"
$avdDir = Join-Path $projectDir "avd"
$avdRepoUrl = "https://github.com/JohnLiang119/avd.git"

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   開始執行 JohnLiang 工作區初始環境建置" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 1. 確保 ..Project 目錄存在
if (-not (Test-Path $projectDir)) {
    Write-Host ">>> 建立專案上層目錄: $projectDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
}

# 2. 下載 avd 專案程式碼
if (-not (Test-Path $avdDir)) {
    Write-Host ">>> 正在從 GitHub 下載 avd 專案 (git clone)..." -ForegroundColor Cyan
    Set-Location $projectDir
    git clone $avdRepoUrl avd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "git clone avd 失敗！請檢查網路連線或 GitHub 存取權限。"
        exit 1
    }
    Write-Host "✅ avd 專案下載完成！" -ForegroundColor Green
} else {
    Write-Host "ℹ️ avd 專案已存在於 $avdDir。" -ForegroundColor Yellow
}

# 3. 執行環境依賴還原
$restoreScript = Join-Path $avdDir "restore_avd.ps1"
if (Test-Path $restoreScript) {
    Write-Host ""
    Write-Host ">>> 正在執行 avd 開發環境還原 (npm install & cap sync)..." -ForegroundColor Cyan
    Set-Location $avdDir
    powershell -ExecutionPolicy Bypass -File $restoreScript
} else {
    Write-Warning "找不到 restore_avd.ps1 腳本。"
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   🎉 JohnLiang 跨電腦開發環境已就緒！" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "📌 專案路徑: $avdDir" -ForegroundColor Green
Write-Host "📌 平時如需同步更新，請執行: .\pull_all.ps1" -ForegroundColor Cyan
Write-Host "📌 如需打包編譯，請執行: ..Project\avd\all.ps1" -ForegroundColor Cyan
Write-Host ""

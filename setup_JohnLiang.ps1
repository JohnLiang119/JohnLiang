[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$targetRoot = "C:\JohnLiang"
$projectDir = Join-Path $targetRoot "..Project"
$avdDir = Join-Path $projectDir "avd"
$workspaceRepoUrl = "https://github.com/JohnLiang119/JohnLiang.git"
$avdRepoUrl = "https://github.com/JohnLiang119/avd.git"

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   開始執行 JohnLiang 全自動工作區環境建置" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 1. 檢查並下載 JohnLiang 工作區環境 (AI 技能、規範與腳本)
if (-not (Test-Path $targetRoot)) {
    Write-Host ">>> [階段一] 正在下載 JohnLiang 工作區環境 (git clone)..." -ForegroundColor Cyan
    git clone $workspaceRepoUrl $targetRoot

    if ($LASTEXITCODE -ne 0) {
        Write-Error "git clone JohnLiang 失敗！請檢查網路連線或 GitHub 存取權限。"
        exit 1
    }
    Write-Host "✅ JohnLiang 工作區環境下載完成！" -ForegroundColor Green
} else {
    Write-Host "ℹ️ [階段一] JohnLiang 工作區已存在於 $targetRoot。" -ForegroundColor Yellow
}

# 2. 確保 ..Project 目錄存在
if (-not (Test-Path $projectDir)) {
    Write-Host ">>> 建立專案上層目錄: $projectDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
}

# 3. 檢查並下載 avd 專案程式碼
if (-not (Test-Path $avdDir)) {
    Write-Host ""
    Write-Host ">>> [階段二] 正在從 GitHub 下載 avd 專案程式碼 (git clone)..." -ForegroundColor Cyan
    Set-Location $projectDir
    git clone $avdRepoUrl avd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "git clone avd 失敗！請檢查網路連線或 GitHub 存取權限。"
        exit 1
    }
    Write-Host "✅ avd 專案下載完成！" -ForegroundColor Green
} else {
    Write-Host "ℹ️ [階段二] avd 專案已存在於 $avdDir。" -ForegroundColor Yellow
}

# 4. 執行專案依賴還原
$restoreScript = Join-Path $avdDir "restore_avd.ps1"
if (Test-Path $restoreScript) {
    Write-Host ""
    Write-Host ">>> [階段三] 正在執行 avd 開發環境還原 (npm install & cap sync)..." -ForegroundColor Cyan
    Set-Location $avdDir
    powershell -ExecutionPolicy Bypass -File $restoreScript
} else {
    Write-Warning "找不到 restore_avd.ps1 腳本。"
}

Set-Location $targetRoot
Write-Host ""
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   🎉 JohnLiang 跨電腦開發環境已全部就緒！" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "📌 工作區路徑: $targetRoot" -ForegroundColor Green
Write-Host "📌 專案路徑:   $avdDir" -ForegroundColor Green
Write-Host "📌 平時如需同步更新，請執行: .\pull_all.ps1" -ForegroundColor Cyan
Write-Host "📌 如需打包編譯，請執行: ..Project\avd\all.ps1" -ForegroundColor Cyan
Write-Host ""
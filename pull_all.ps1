[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$workspaceRoot = $PSScriptRoot
$projectDir = Join-Path $workspaceRoot "..Project"
$avdDir = Join-Path $projectDir "avd"

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   開始執行 JohnLiang 全自動拉取更新 (Pull)" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 階段一：拉取工作區 (JohnLiang) 最新變更
Write-Host ">>> [階段一] 正在同步工作區與 AI 技能 (C:\JohnLiang)..." -ForegroundColor Cyan
Set-Location $workspaceRoot

# 檢查是否有未提交變更
$wsStatus = git status --porcelain
if ($wsStatus) {
    Write-Warning "工作區有未提交的修改，正在嘗試暫存 (git stash)..."
    git stash
}

git pull origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 工作區 (JohnLiang) 同步成功！" -ForegroundColor Green
} else {
    Write-Warning "工作區同步失敗，請檢查網路或遠端連線。"
}

# 階段二：拉取專案 (avd) 最新變更
Write-Host ""
Write-Host ">>> [階段二] 正在同步 avd 專案程式碼 (..Project\avd)..." -ForegroundColor Cyan

if (Test-Path $avdDir) {
    Set-Location $avdDir
    
    $avdStatus = git status --porcelain
    if ($avdStatus) {
        Write-Warning "avd 專案有未提交的修改，正在嘗試暫存 (git stash)..."
        git stash
    }

    git pull origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ avd 專案同步成功！" -ForegroundColor Green
    } else {
        Write-Warning "avd 專案同步失敗，請檢查網路或遠端連線。"
    }
} else {
    Write-Host "ℹ️ 尚未找到 avd 專案目錄，建議您先執行: .\setup_workspace.ps1 進行初次建置。" -ForegroundColor Yellow
}

Set-Location $workspaceRoot
Write-Host ""
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   🎉 全自動同步更新已全部完成！" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

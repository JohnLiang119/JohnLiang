[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Message,
    [Parameter(Mandatory=$false)]
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$targetProject = Join-Path $scriptDir "avd"

Set-Location $targetProject

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   開始執行 avd Git 提交與推送作業" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 清理可能的 git index 鎖定檔案
if (Test-Path "$targetProject\.git\index.lock") {
    Remove-Item "$targetProject\.git\index.lock" -Force -ErrorAction SilentlyContinue
}

# 確保遠端 URL 指向 avd.git
$remoteUrl = git remote get-url origin 2>$null
if ($remoteUrl -match "avd_vue") {
    git remote set-url origin https://github.com/JohnLiang119/avd.git
}

Write-Host ">>> 檢查目前變更狀態 (git status)..." -ForegroundColor Cyan
git status

$status = git status --porcelain
if ($status) {
    # 取得 Commit 訊息
    if (-not $Message) {
        $Message = Read-Host "請輸入 Commit Message (例如: feat: 新增功能描述)"
    }

    if (-not $Message) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $Message = "chore: 自動儲存與提交 ($timestamp)"
    }

    Write-Host ""
    Write-Host ">>> 正在暫存所有變更 (git add .)..." -ForegroundColor Cyan
    git add .

    Write-Host ">>> 正在提交變更 (git commit)..." -ForegroundColor Cyan
    git commit -m "$Message"

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Commit 成功！最新紀錄：" -ForegroundColor Green
        git log -n 1 --oneline
    } else {
        Write-Error "Git Commit 失敗！"
        exit 1
    }
} else {
    Write-Host "ℹ️ 目前無任何未提交的本地變更。" -ForegroundColor Yellow
}

# 自動執行 Git Push 推送至 GitHub
if (-not $NoPush) {
    Write-Host ""
    Write-Host ">>> 正在推送至 GitHub 遠端倉庫 (git push origin main)..." -ForegroundColor Cyan
    git push -u origin main

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 成功！所有最新變更已同步推送到 GitHub 遠端倉庫！" -ForegroundColor Green
    } else {
        Write-Warning "推送至 GitHub 失敗！請確認您已在 GitHub 建立 'avd' 倉庫且網路連線正常。"
    }
}

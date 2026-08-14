[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Message,
    [Parameter(Mandatory=$false)]
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"
$workspaceRoot = $PSScriptRoot

Set-Location $workspaceRoot

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   開始執行 JohnLiang 工作區 Git 提交作業" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 清理可能的 git index 鎖定檔案
if (Test-Path "$workspaceRoot\.git\index.lock") {
    Remove-Item "$workspaceRoot\.git\index.lock" -Force -ErrorAction SilentlyContinue
}

Write-Host ">>> 檢查目前工作區變更狀態 (git status)..." -ForegroundColor Cyan
git status

$status = git status --porcelain
if ($status) {
    # 取得 Commit 訊息
    if (-not $Message) {
        $Message = Read-Host "請輸入 Commit Message (例如: feat: 更新 AI 技能或工作流)"
    }

    if (-not $Message) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $Message = "chore: 工作區環境與技能自動存檔 ($timestamp)"
    }

    Write-Host ""
    Write-Host ">>> 正在暫存工作區變更 (git add .)..." -ForegroundColor Cyan
    git add .

    Write-Host ">>> 正在提交變更 (git commit)..." -ForegroundColor Cyan
    git commit -m "$Message"

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ 工作區 Commit 成功！最新紀錄：" -ForegroundColor Green
        git log -n 1 --oneline
    } else {
        Write-Error "Git Commit 失敗！"
        exit 1
    }
} else {
    Write-Host "ℹ️ 目前無任何未提交的本地變更。" -ForegroundColor Yellow
}

# 檢查與執行 Git Push
if (-not $NoPush) {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl) {
        Write-Host ""
        Write-Host ">>> 正在推送至 GitHub 遠端工作區倉庫 (git push origin main)..." -ForegroundColor Cyan
        git push -u origin main

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "🎉 成功！工作區設定與 AI 技能已同步推送到 GitHub 遠端倉庫！" -ForegroundColor Green
        } else {
            Write-Warning "推送至 GitHub 失敗！請確認遠端倉庫已建立且網路連線正常。"
        }
    } else {
        Write-Host ""
        Write-Host "ℹ️ 提示：目前尚未設定 GitHub 遠端倉庫 (origin)。" -ForegroundColor Yellow
        Write-Host "若要同步至 GitHub，請先在 GitHub 建立倉庫（如 JohnLiang），然後執行：" -ForegroundColor DarkGray
        Write-Host "  git remote add origin https://github.com/JohnLiang119/JohnLiang.git" -ForegroundColor Cyan
        Write-Host "  git push -u origin main" -ForegroundColor Cyan
    }
}

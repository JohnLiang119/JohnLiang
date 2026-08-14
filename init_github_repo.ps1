<#
.SYNOPSIS
    自動在 GitHub 上建立遠端倉庫並完成首次 Commit 與 Push 的自動化腳本。

.DESCRIPTION
    利用 GitHub CLI (gh) 與 Git 工具，自動檢查登入狀態、初始化本地 Git、
    在 GitHub 上建立對應的 Public/Private 儲存庫，並設定 remote origin 推送至 main 分支。

.PARAMETER TargetPath
    目標專案路徑，預設為當前執行路徑。

.PARAMETER RepoName
    GitHub 倉庫名稱，預設為目標資料夾名稱。

.PARAMETER Visibility
    倉庫可見度：public 或 private，預設為 public。

.PARAMETER Message
    首次 Commit 訊息，預設為 "feat: initial commit"。

.EXAMPLE
    .\init_github_repo.ps1
    自動以當前目錄名稱在 GitHub 建立 public 倉庫並推送。

.EXAMPLE
    .\init_github_repo.ps1 -TargetPath "..\Project\my-app" -RepoName "my-app" -Private
    建立名為 my-app 的私有倉庫並推送。
#>
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$TargetPath = "",

    [Parameter(Position=1, Mandatory=$false)]
    [string]$RepoName = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("public", "private")]
    [string]$Visibility = "public",

    [Parameter(Mandatory=$false)]
    [switch]$Private,

    [Parameter(Mandatory=$false)]
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"

if ($Private) {
    $Visibility = "private"
}

# 決定目標路徑
if (-not $TargetPath) {
    $TargetPath = $PWD.Path
} else {
    $TargetPath = (Resolve-Path $TargetPath).Path
}

# 決定 Repo 名稱
if (-not $RepoName) {
    $RepoName = Split-Path $TargetPath -Leaf
}

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   GitHub 遠端倉庫自動化建置與推送作業" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "📌 目標路徑 : $TargetPath" -ForegroundColor Cyan
Write-Host "📌 倉庫名稱 : $RepoName" -ForegroundColor Cyan
Write-Host "📌 倉庫屬性 : $Visibility" -ForegroundColor Cyan
Write-Host ""

# 1. 檢查必要工具：Git 與 GitHub CLI (gh)
Write-Host ">>> [步驟 1/5] 檢查 Git 與 GitHub CLI (gh) 安裝與登入狀態..." -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "找不到 Git 工具，請先安裝 Git 並加入 PATH！"
    exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "找不到 GitHub CLI (gh) 工具，請先安裝 gh！"
    exit 1
}

# 檢查 gh 登入狀態
$authStatus = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI 尚未登入！請先於終端機執行 'gh auth login' 完成驗證後再執行此腳本。"
    exit 1
}

# 取得目前登入的 GitHub 帳號
$ghUser = (& gh api user -q ".login" 2>$null)
if (-not $ghUser) {
    Write-Error "無法取得 GitHub 登入使用者資訊，請確認網路連線與憑證。"
    exit 1
}
Write-Host "✅ 驗證成功！目前登入帳號: $ghUser" -ForegroundColor Green

# 切換至目標目錄
Set-Location $TargetPath

# 清理可能的 git index 鎖定檔案
if (Test-Path "$TargetPath\.git\index.lock") {
    Remove-Item "$TargetPath\.git\index.lock" -Force -ErrorAction SilentlyContinue
}

# 2. 初始化本地 Git 倉庫（若尚未初始化）
Write-Host ""
Write-Host ">>> [步驟 2/5] 檢查本地 Git 版本庫狀態..." -ForegroundColor Cyan
if (-not (Test-Path "$TargetPath\.git")) {
    Write-Host "ℹ️ 尚未初始化 Git，正在執行 git init..." -ForegroundColor Yellow
    git init
    git branch -M main
} else {
    Write-Host "ℹ️ 本地 Git 版本庫已存在。" -ForegroundColor Yellow
    # 確保預設分支為 main
    $currentBranch = (git branch --show-current 2>$null)
    if (-not $currentBranch) {
        git checkout -B main 2>$null
    }
}

# 3. 處理變更並建立 Commit
Write-Host ""
Write-Host ">>> [步驟 3/5] 檢查本地檔案變更與暫存 (git status)..." -ForegroundColor Cyan
$status = git status --porcelain
$hasCommit = (git log -n 1 2>$null)

if ($status -or (-not $hasCommit)) {
    if (-not $Message) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $Message = "feat: 初始化專案與提交 ($timestamp)"
    }

    Write-Host ">>> 暫存所有檔案 (git add .)..." -ForegroundColor Cyan
    git add .

    Write-Host ">>> 提交變更 (git commit)..." -ForegroundColor Cyan
    git commit -m "$Message"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Commit 成功！最新紀錄：" -ForegroundColor Green
        git log -n 1 --oneline
    } else {
        if (-not $hasCommit) {
            Write-Error "Git Commit 失敗！"
            exit 1
        }
    }
} else {
    Write-Host "ℹ️ 目前無未提交的本地變更。" -ForegroundColor Yellow
}

# 4. 檢查 GitHub 遠端倉庫是否存在
Write-Host ""
Write-Host ">>> [步驟 4/5] 檢查 GitHub 遠端倉庫狀態 ($ghUser/$RepoName)..." -ForegroundColor Cyan

$repoExists = $false
$repoViewOutput = & gh repo view "$ghUser/$RepoName" 2>&1
if ($LASTEXITCODE -eq 0) {
    $repoExists = $true
    Write-Host "ℹ️ GitHub 上已存在倉庫: $ghUser/$RepoName" -ForegroundColor Yellow
} else {
    Write-Host "ℹ️ GitHub 上尚未存在倉庫，正在自動建立 ($Visibility)..." -ForegroundColor Yellow
    $createCmd = "gh repo create `"$RepoName`" --$Visibility --confirm"
    & gh repo create "$RepoName" --$Visibility
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "在 GitHub 上建立倉庫失敗！請檢查倉庫名稱是否重複或特殊字元。"
        exit 1
    }
    Write-Host "✅ 成功在 GitHub 建立倉庫: $ghUser/$RepoName" -ForegroundColor Green
    $repoExists = $true
}

# 設定遠端 remote origin
$expectedRemoteUrl = "https://github.com/$ghUser/$RepoName.git"
$currentRemoteUrl = (git remote get-url origin 2>$null)

if (-not $currentRemoteUrl) {
    Write-Host ">>> 加入遠端倉庫 origin -> $expectedRemoteUrl" -ForegroundColor Cyan
    git remote add origin $expectedRemoteUrl
} elseif ($currentRemoteUrl -ne $expectedRemoteUrl) {
    Write-Host ">>> 更新遠端倉庫 origin -> $expectedRemoteUrl" -ForegroundColor Cyan
    git remote set-url origin $expectedRemoteUrl
} else {
    Write-Host "ℹ️ 遠端倉庫 origin URL 已正確設定。" -ForegroundColor Yellow
}

# 5. 推送至 GitHub main 分支
Write-Host ""
Write-Host ">>> [步驟 5/5] 正在推送至 GitHub 遠端倉庫 (git push -u origin main)..." -ForegroundColor Cyan

$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git push -u origin main
$pushCode = $LASTEXITCODE
$ErrorActionPreference = $prevEAP

if ($pushCode -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "🎉 恭喜！遠端倉庫建置與首次推送已順利完成！" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "🌐 GitHub 倉庫網址: https://github.com/$ghUser/$RepoName" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Warning "推送失敗！請確認分支名稱是否為 main，或手動執行 'git push -u origin main --force'（若遠端有衝突需覆蓋）。"
}
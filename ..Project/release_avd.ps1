# =========================================================
#   AVD 一鍵自動發布至 GitHub Releases (APK + Windows MSI)
# =========================================================
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Tag = "",

    [Parameter(Position=1, Mandatory=$false)]
    [string]$Title = "",

    [Parameter(Mandatory=$false)]
    [string]$Notes = "",

    [Parameter(Mandatory=$false)]
    [switch]$Draft,

    [Parameter(Mandatory=$false)]
    [switch]$P
)

$ErrorActionPreference = "Stop"

# 自動定位 avd 專案目錄
$scriptDir = $PSScriptRoot
if (Test-Path (Join-Path $scriptDir "avd")) {
    $avdDir = Join-Path $scriptDir "avd"
} elseif (Test-Path (Join-Path $scriptDir "package.json")) {
    $avdDir = $scriptDir
} else {
    $avdDir = "C:\JohnLiang\..Project\avd"
}

Set-Location $avdDir

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   開始執行 AVD 一鍵 GitHub Release 發布" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 1. 確保 GitHub CLI (gh) 環境變數與安裝
$ghPath = "C:\Program Files\GitHub CLI"
if ((Test-Path $ghPath) -and ($env:PATH -notmatch [regex]::Escape($ghPath))) {
    $env:PATH = "$ghPath;$env:PATH"
}

Write-Host "--- 步驟 1/5: 檢查 GitHub CLI (gh) 工具與登入狀態..." -ForegroundColor Cyan
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "尚未偵測到 GitHub CLI，正在嘗試透過 winget 自動安裝..." -ForegroundColor Yellow
    winget install --id GitHub.cli --exact --silent --accept-source-agreements --accept-package-agreements
    if (Test-Path $ghPath) {
        $env:PATH = "$ghPath;$env:PATH"
    }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "找不到 GitHub CLI (gh) 工具！請先手動安裝 GitHub CLI (https://cli.github.com/)。"
    exit 1
}

# 檢查登入狀態
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
$authOutput = & gh auth status 2>&1
$isLoggedIn = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prevEAP

if (-not $isLoggedIn) {
    Write-Host "偵測到 GitHub CLI 尚未登入！" -ForegroundColor Yellow
    Write-Host "正在為您啟動網頁快速登入..." -ForegroundColor Cyan
    & gh auth login --web -h github.com -p https
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI 登入授權未完成，請完成登入後再次執行此腳本。"
        exit 1
    }
}

# 取得目前登入的 GitHub 帳號與倉庫
$ghUser = (& gh api user -q ".login" 2>$null)
if (-not $ghUser) {
    $ghUser = "JohnLiang119"
}
$repoName = "avd"
$fullRepo = "$ghUser/$repoName"
Write-Host "GitHub CLI 驗證成功！登入帳號: $ghUser (目標倉庫: $fullRepo)" -ForegroundColor Green

# 2. 自動讀取版本號
Write-Host ""
Write-Host "--- 步驟 2/5: 讀取專案版號與發布資訊..." -ForegroundColor Cyan

$version = "1.0.3"
if (Test-Path "package.json") {
    try {
        $pkg = Get-Content "package.json" -Raw | ConvertFrom-Json
        if ($pkg.version) { $version = $pkg.version }
    } catch {}
}

if (-not $Tag) {
    $Tag = "v$version"
}

if (-not $Title) {
    $Title = "v$version 官方發布"
}

Write-Host "  當前發布版本 (Version) : $version" -ForegroundColor Cyan
Write-Host "  發布標籤名稱 (Tag)     : $Tag" -ForegroundColor Cyan
Write-Host "  發布標題 (Title)       : $Title" -ForegroundColor Cyan

# 3. 前置 Git 狀態檢查與自動同步
Write-Host ""
Write-Host "--- 步驟 3/5: 檢查本機 Git 狀態並同步遠端倉庫..." -ForegroundColor Cyan

$gitStatus = & git status --porcelain
if ($gitStatus) {
    Write-Host "偵測到本機有尚未提交的檔案變更，正在自動提交並推送..." -ForegroundColor Yellow
    & git add -A
    $nowStr = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $commitMsg = "chore: v$version 發布前自動同步 ($nowStr)"
    & git commit -m "$commitMsg"
    & git push origin main
    Write-Host "程式碼已成功同步推送到 GitHub main 分支！" -ForegroundColor Green
} else {
    Write-Host "本機工作區乾淨，無未提交之變更。" -ForegroundColor Green
    try { & git push origin main 2>&1 | Out-Null } catch {}
}

# 4. 尋找並驗證 APK 與 MSI 安裝包
Write-Host ""
Write-Host "--- 步驟 4/5: 搜尋待發布的安裝包檔案..." -ForegroundColor Cyan

# 尋找 APK (支援多個架構分拆的 APK)
$apkFilter1 = "AVD_" + $version + "*.apk"
$apkFiles = @()
$foundApks = Get-ChildItem -Path . -Filter $apkFilter1 -ErrorAction SilentlyContinue
if ($foundApks) {
    $apkFiles += $foundApks
} else {
    $fallbackApks = Get-ChildItem -Path . -Filter "AVD_*.apk" -ErrorAction SilentlyContinue
    if ($fallbackApks) { $apkFiles += $fallbackApks }
}

# 尋找 MSI (優先尋找當前版本)
$msiFilter1 = "AVD_" + $version + "*.msi"
$msiFilter2 = "*" + $version + "*.msi"
$msiCandidates = @(
    (Get-ChildItem -Path . -Filter $msiFilter1 -ErrorAction SilentlyContinue | Select-Object -First 1),
    (Get-ChildItem -Path "src-tauri\target\release\bundle\msi" -Filter $msiFilter2 -ErrorAction SilentlyContinue | Select-Object -First 1),
    (Get-ChildItem -Path . -Filter "AVD_*.msi" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1),
    (Get-ChildItem -Path "src-tauri\target\release\bundle\msi" -Filter "*.msi" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
)
$msiFile = ($msiCandidates | Where-Object { $null -ne $_ } | Select-Object -First 1)

$uploadFiles = @()

if ($apkFiles.Count -gt 0) {
    foreach ($apk in $apkFiles) {
        $apkName = $apk.Name
        $apkSizeMB = [math]::Round($apk.Length / 1MB, 2)
        Write-Host "  找到 APK 安裝檔: $apkName - $apkSizeMB MB" -ForegroundColor Green
        $uploadFiles += $apk.FullName
    }
} else {
    Write-Warning "未找到 APK 安裝檔！"
}

if ($msiFile) {
    $msiName = $msiFile.Name
    $msiSizeMB = [math]::Round($msiFile.Length / 1MB, 2)
    Write-Host "  找到 MSI 安裝檔: $msiName - $msiSizeMB MB" -ForegroundColor Green
    $uploadFiles += $msiFile.FullName
} else {
    Write-Warning "未找到 MSI 安裝檔！"
}

if ($uploadFiles.Count -eq 0) {
    Write-Error "找不到任何可上傳的 APK 或 MSI 安裝包！請先手動執行 .\all.ps1 進行全平台編譯打包。"
    exit 1
}

# 5. 發布至 GitHub Releases
Write-Host ""
Write-Host "--- 步驟 5/5: 正在發布/更新 GitHub Release $Tag ..." -ForegroundColor Cyan

# 檢查遠端是否已存在此 Tag 的 Release
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
$null = & gh release view $Tag --repo $fullRepo 2>$null
$releaseExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prevEAP

if ($releaseExists) {
    Write-Host "偵測到遠端已存在 Release $Tag，正在上傳/覆蓋安裝包附件..." -ForegroundColor Yellow
    foreach ($file in $uploadFiles) {
        $fileName = Split-Path $file -Leaf
        Write-Host "  正在上傳附件: $fileName ..." -ForegroundColor Cyan
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & gh release upload $Tag "$file" --repo $fullRepo --clobber
        $ErrorActionPreference = $prevEAP
    }
    if (-not $P) {
        Write-Host "  正在確認 Release $Tag 為正式發布 Latest..." -ForegroundColor Cyan
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & gh release edit $Tag --repo $fullRepo --draft=false --prerelease=false --latest
        $ErrorActionPreference = $prevEAP
    }
} else {
    Write-Host "正在建立全新 GitHub Release $Tag ..." -ForegroundColor Yellow
    
    $cmdArgs = @("release", "create", $Tag)
    foreach ($file in $uploadFiles) {
        $cmdArgs += $file
    }
    $cmdArgs += "--repo"
    $cmdArgs += $fullRepo
    $cmdArgs += "--title"
    $cmdArgs += $Title

    if ($Notes) {
        $cmdArgs += "--notes"
        $cmdArgs += $Notes
    } else {
        $prevConsoleEncoding = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        
        $lastCommit = (& git log -1 --pretty=%s).Trim()
        if ($lastCommit -match "^chore: v\d+\.\d+\.\d+ 發布前自動同步") {
            $lastCommit = (& git log -2 --pretty=%s)[1].Trim()
        }
        
        [Console]::OutputEncoding = $prevConsoleEncoding
        
        $defaultNotes = $lastCommit
        if (-not $defaultNotes) {
            $defaultNotes = "AVD v$version 版本更新"
        }
        $cmdArgs += "--notes"
        $cmdArgs += $defaultNotes
    }

    if ($Draft) {
        $cmdArgs += "--draft"
    }

    if ($P) {
        $cmdArgs += "--prerelease"
    } else {
        $cmdArgs += "--latest"
    }

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & gh @cmdArgs
    $createCode = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  恭喜！AVD $Tag 一鍵發布已圓滿成功！" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "  Release 網址: https://github.com/$fullRepo/releases/tag/$Tag" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Error "發布 GitHub Release 失敗，請檢查網路連線或權限！"
    exit 1
}

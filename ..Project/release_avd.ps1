<#
.SYNOPSIS
    自動將 AVD 專案編譯產物 (APK 與 MSI) 發布至 GitHub Releases 的自動化腳本。

.DESCRIPTION
    利用 GitHub CLI (gh) 工具，自動偵測專案版號 (如 3.0.1)，
    尋找對應的 AVD_${version}.apk 與 AVD_${version}_*.msi 安裝包，
    並自動在 GitHub 倉庫 (JohnLiang119/avd) 上建立或更新 Release，上傳二進制附件。

.PARAMETER Tag
    發布的 Git Tag 標籤名稱，預設為 "v" + package.json 版號 (例如 "v3.0.1")。

.PARAMETER Title
    Release 標題，預設為 "v$version 官方發布"。

.PARAMETER Notes
    Release 說明內容，若未指定則自動採用預設或提示輸入。

.PARAMETER Draft
    是否建立為草稿 (Draft)。

.PARAMETER Prerelease
    是否設定為預發布版本 (Pre-release)。
#>
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
    [switch]$Prerelease
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
Write-Host "   開始執行 AVD GitHub Release 發布作業" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

# 1. 檢查 GitHub CLI (gh) 安裝與登入狀態
Write-Host ">>> [步驟 1/4] 檢查 GitHub CLI (gh) 工具與登入狀態..." -ForegroundColor Cyan
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "找不到 GitHub CLI (gh) 工具，請先安裝 gh！"
    exit 1
}

$authStatus = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI 尚未登入！請先於終端機執行 'gh auth login' 完成驗證後再執行此腳本。"
    exit 1
}

# 取得目前登入的 GitHub 帳號
$ghUser = (& gh api user -q ".login" 2>$null)
if (-not $ghUser) {
    $ghUser = "JohnLiang119"
}
$repoName = "avd"
$fullRepo = "$ghUser/$repoName"
Write-Host "✅ 驗證成功！目前登入帳號: $ghUser (目標倉庫: $fullRepo)" -ForegroundColor Green

# 2. 自動讀取版本號與設定 Tag
Write-Host ""
Write-Host ">>> [步驟 2/4] 讀取專案版號與發布資訊..." -ForegroundColor Cyan

$version = "3.0.1"
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

Write-Host "📌 發布版本 (Version) : $version" -ForegroundColor Cyan
Write-Host "📌 標籤名稱 (Tag)     : $Tag" -ForegroundColor Cyan
Write-Host "📌 標題 (Title)       : $Title" -ForegroundColor Cyan

# 3. 搜尋要上傳的安裝包檔案 (APK 與 MSI)
Write-Host ""
Write-Host ">>> [步驟 3/4] 尋找待發布的安裝包檔案..." -ForegroundColor Cyan

# 尋找 APK
$apkCandidates = @(
    (Get-ChildItem -Path . -Filter "AVD_${version}*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1),
    (Get-ChildItem -Path . -Filter "AVD_*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1),
    (Get-ChildItem -Path "android\app\build\outputs\apk\debug" -Filter "*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1)
)
$apkFile = ($apkCandidates | Where-Object { $_ -ne $null } | Select-Object -First 1)

# 尋找 MSI
$msiCandidates = @(
    (Get-ChildItem -Path . -Filter "AVD_${version}*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1),
    (Get-ChildItem -Path . -Filter "AVD_*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1),
    (Get-ChildItem -Path "src-tauri\target\release\bundle\msi" -Filter "*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1)
)
$msiFile = ($msiCandidates | Where-Object { $_ -ne $null } | Select-Object -First 1)

$uploadFiles = @()

if ($apkFile) {
    Write-Host "📦 找到 APK 安裝檔: $($apkFile.Name) ($([math]::Round($apkFile.Length / 1MB, 2)) MB)" -ForegroundColor Green
    $uploadFiles += $apkFile.FullName
} else {
    Write-Warning "未找到 APK 安裝檔！"
}

if ($msiFile) {
    Write-Host "📦 找到 MSI 安裝檔: $($msiFile.Name) ($([math]::Round($msiFile.Length / 1MB, 2)) MB)" -ForegroundColor Green
    $uploadFiles += $msiFile.FullName
} else {
    Write-Warning "未找到 MSI 安裝檔！"
}

if ($uploadFiles.Count -eq 0) {
    Write-Error "找不到任何可上傳的 APK 或 MSI 安裝包！請先執行 '.\all.ps1' 進行編譯打包。"
    exit 1
}

# 4. 發布至 GitHub Releases
Write-Host ""
Write-Host ">>> [步驟 4/4] 正在發布/更新 GitHub Release ($Tag)..." -ForegroundColor Cyan

# 檢查遠端是否已存在此 Tag 的 Release
$existingRelease = & gh release view $Tag --repo $fullRepo 2>&1
$releaseExists = ($LASTEXITCODE -eq 0)

if ($releaseExists) {
    Write-Host "ℹ️ 偵測到遠端已存在 Release $Tag，正在上傳/覆蓋安裝包附件..." -ForegroundColor Yellow
    foreach ($file in $uploadFiles) {
        $fileName = Split-Path $file -Leaf
        Write-Host ">>> 正在上傳附件: $fileName ..." -ForegroundColor Cyan
        & gh release upload $Tag "$file" --repo $fullRepo --clobber
    }
} else {
    Write-Host "ℹ️ 正在建立全新 GitHub Release ($Tag)..." -ForegroundColor Yellow
    
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
        $cmdArgs += "--generate-notes"
    }

    if ($Draft) {
        $cmdArgs += "--draft"
    }

    if ($Prerelease) {
        $cmdArgs += "--prerelease"
    }

    $cmdArgs += "--clobber"

    & gh @cmdArgs
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "🎉 恭喜！AVD $Tag 安裝包已成功發布至 GitHub Release！" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "🌐 Release 網址: https://github.com/$fullRepo/releases/tag/$Tag" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Error "發布 GitHub Release 失敗，請檢查網路連線或權限！"
    exit 1
}
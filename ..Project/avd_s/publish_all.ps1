[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [switch]$P
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   啟動 AVD 一鍵自動化：打包 -> 提交 -> 發布" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

if (-not $Message) {
    # 每次進版時，AI 會自動更新這裡的說明內容
    $Message = "優化頂部控制列改為雙層排版設計 (v1.0.21)"
}

# 1. 執行打包
Write-Host ">>> [1/3] 正在執行打包 (all.ps1)..." -ForegroundColor Cyan
$avdDir = Join-Path (Split-Path $scriptDir -Parent) "avd"
Set-Location $avdDir
& .\all.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Error "打包失敗：請檢查 all.ps1 輸出。"
    exit 1
}

# 2. 執行提交
Write-Host ""
Write-Host ">>> [2/3] 正在執行提交與推送 (commit_avd.ps1)..." -ForegroundColor Cyan
Set-Location $scriptDir
& .\commit_avd.ps1 -Message $Message
if ($LASTEXITCODE -ne 0) {
    Write-Error "提交失敗：請檢查 commit_avd.ps1 輸出。"
    exit 1
}

# 3. 執行發布
Write-Host ""
Write-Host ">>> [3/3] 正在執行 GitHub Release (release_avd.ps1)..." -ForegroundColor Cyan
Set-Location (Split-Path $scriptDir -Parent)
if ($P) {
    & .\release_avd.ps1 -Notes $Message -P
} else {
    & .\release_avd.ps1 -Notes $Message
}
if ($LASTEXITCODE -ne 0) {
    Write-Error "發布失敗：請檢查 release_avd.ps1 輸出。"
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "   🎉 全部完成：自動打包、發布已順利結束！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
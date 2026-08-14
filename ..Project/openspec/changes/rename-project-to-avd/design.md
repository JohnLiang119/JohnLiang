# 設計文件：專案更名為 avd

## 架構與影響分析

### 1. 資料夾更名
- 舊路徑：`c:\JohnLiang\..Project\avd_vue`
- 新路徑：`c:\JohnLiang\..Project\avd`
- Git 倉庫內部資訊（`.git/`）完全保留，遠端 URL 與歷史紀錄不受更名影響。

### 2. 檔案更名與內容調整清單
- `c:\JohnLiang\..Project\commit_avd_vue.ps1` -> `c:\JohnLiang\..Project\commit_avd.ps1`
  - 更新 `$targetProject = Join-Path $scriptDir "avd"`
  - 更新 Log 訊息為 `avd Git 提交作業`
- `backup_avd_vue.ps1` -> `backup_avd.ps1`
  - 更新 `$zipName = "avd_backup_$timestamp.zip"`
  - 更新 7z 排除清單 `-xr!backup_avd.ps1`
- `restore_avd_vue.ps1` -> `restore_avd.ps1`
  - 更新 Log 提示訊息為 `avd 開發環境`
- `package.json` & `package-lock.json`
  - 更新 `name: "avd"`
- `.agent/rules/do-not-auto-run-all-ps1.md`
  - 更新參照名稱為 `avd`

### 3. 編碼規範
- 所有 PowerShell 腳本以 **UTF-8 with BOM** 儲存。

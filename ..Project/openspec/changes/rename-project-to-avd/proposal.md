# 變更提案：將專案名稱由 avd_vue 更名為 avd

## 為什麼需要此變更？ (Why)
為了使專案名稱更簡潔且統一跨平台命名（AVD），將資料夾名稱由 `c:\JohnLiang\..Project\avd_vue` 更名為 `c:\JohnLiang\..Project\avd`，並同步調整相關專案配置與自動化腳本。

## 變更範圍 (What Changes)
1. **資料夾更名**：
   - 將 `c:\JohnLiang\..Project\avd_vue` 更名為 `c:\JohnLiang\..Project\avd`
2. **專案配置檔更新**：
   - `package.json`：`name` 由 `avd_vue` 改為 `avd`
   - `package-lock.json`：`name` 由 `avd_vue` 改為 `avd`
3. **腳本更名與內容更新**：
   - `c:\JohnLiang\..Project\commit_avd_vue.ps1` 更名為 `commit_avd.ps1`，內部路徑指向 `avd`
   - `backup_avd_vue.ps1` 更名為 `backup_avd.ps1`，壓縮檔名與排除條件同步調整
   - `restore_avd_vue.ps1` 更名為 `restore_avd.ps1`
4. **規則與說明文件**：
   - 更新 `.agent/rules/do-not-auto-run-all-ps1.md` 中的專案路徑描述

## 驗證方式 (Verification)
1. 確認資料夾已成功更名為 `c:\JohnLiang\..Project\avd`。
2. 執行 `commit_avd.ps1` 驗證 Git 狀態檢測與目標路徑指向正確。
3. 驗證 `package.json` 與相關腳本語法正確。

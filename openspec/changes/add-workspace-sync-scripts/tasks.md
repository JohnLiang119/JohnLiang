## 1. 建立新電腦初次設置腳本 (情境一)

- [x] 1.1 建立 `C:\JohnLiang\setup_workspace.ps1`（自動 clone avd 並執行 restore_avd.ps1，UTF-8 with BOM）

## 2. 建立日常切換電腦更新拉取腳本 (情境二)

- [x] 2.1 建立 `C:\JohnLiang\pull_all.ps1`（自動依序 pull 工作區與 avd 專案，UTF-8 with BOM）

## 3. 工作區設定與腳本追蹤維護

- [x] 3.1 更新 `C:\JohnLiang\.gitignore` 確保 `!setup_workspace.ps1` 與 `!pull_all.ps1` 納入追蹤
- [x] 3.2 執行腳本語法與流程驗證測試

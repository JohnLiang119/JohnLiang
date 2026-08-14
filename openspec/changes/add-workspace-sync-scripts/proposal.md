## Why

使用者在多台電腦之間切換開發或在新電腦初次設定時，需要自動化腳本來快速完成「專案初始 Clone 與依賴還原（情境一）」以及「日常一鍵雙向拉取更新（情境二）」，以避免手動輸入多個 Git 與路徑指令。

## What Changes

- **情境一腳本：`setup_JohnLiang.ps1`（新電腦初始環境建置）**：
  - 自動檢測 `C:\JohnLiang` 是否存在；若不存在，自動自 GitHub (`https://github.com/JohnLiang119/JohnLiang.git`) clone 下來。
  - 自動檢測 `C:\JohnLiang\..Project\avd` 是否存在；若不存在，自動自 GitHub (`https://github.com/JohnLiang119/avd.git`) clone 下來。
  - 自動呼叫 `restore_avd.ps1` 還原 `node_modules` 套件與 Android 資源。
- **情境二腳本：`pull_all.ps1`（日常一鍵拉取同步）**：
  - 自動執行 `C:\JohnLiang` 工作區的 `git pull`（同步最新 AI 技能、工作流與規範）。
  - 自動執行 `C:\JohnLiang\..Project\avd` 專案的 `git pull`（同步最新應用程式碼）。
- **更新工作區 `.gitignore`**：
  - 確保 `!setup_JohnLiang.ps1` 與 `!pull_all.ps1` 被工作區版本控制正常追蹤。

## Capabilities

### New Capabilities
- `workspace-sync-scripts`: 提供 `setup_JohnLiang.ps1` 與 `pull_all.ps1`，實現跨電腦一鍵專案環境安裝與日常全自動更新。

### Modified Capabilities
<!-- 無既有規格修改 -->

## Impact

- 在 `C:\JohnLiang\` 新增兩個 PowerShell 腳本，簡化跨電腦操作。
- **編碼規範遵循**：所有腳本檔案（`.ps1`）一律強制使用 **UTF-8 with BOM** 格式儲存，確保 Windows PowerShell 終端機繁體中文顯示完全相容無亂碼。

## Purpose

提供跨電腦開發環境之一鍵初始設置腳本（`setup_JohnLiang.ps1`）與日常雙向更新拉取腳本（`pull_all.ps1`），實現專案原始碼與工作區設定的高效同步。

## ADDED Requirements

### Requirement: Workspace Initial Setup Script Execution
系統必須在 `C:\JohnLiang` 根目錄提供 PowerShell 腳本 `setup_JohnLiang.ps1`。當執行時，檢查 `..Project/avd` 是否存在；若不存在則自動自 GitHub (`https://github.com/JohnLiang119/avd.git`) clone 下來，並自動觸發 `restore_avd.ps1` 還原依賴。

#### Scenario: Setup workspace on a clean machine
- **WHEN** 使用者在新電腦執行 `setup_JohnLiang.ps1`
- **THEN** 系統自動下載 `avd` 專案並完成依賴套件與 Android 資源還原

### Requirement: All-in-One Pull Script Execution
系統必須在 `C:\JohnLiang` 根目錄提供 PowerShell 腳本 `pull_all.ps1`。當執行時，自動依序完成工作區（`JohnLiang`）與子專案（`..Project/avd`）之最新變更拉取（`git pull`）。

#### Scenario: Daily update sync
- **WHEN** 使用者執行 `pull_all.ps1`
- **THEN** 系統依序對 `C:\JohnLiang` 與 `C:\JohnLiang\..Project\avd` 執行 `git pull` 並回報最新版本狀態

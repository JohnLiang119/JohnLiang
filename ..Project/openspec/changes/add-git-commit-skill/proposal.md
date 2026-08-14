## Why

原本規劃經由 Skill 進行 Git 提交，使用者更正希望直接撰寫為 PowerShell 腳本 (`commit_avd_vue.ps1`) 置於 `c:\JohnLiang\..Project` 層級，以簡化為單一指令腳本操作。

## What Changes

- 在 `c:\JohnLiang\..Project` 目錄下建立 PowerShell 腳本 `commit_avd_vue.ps1`。
- 移除先前的 Skill 設定，改以自動化 PowerShell 腳本進行 Git 狀態檢查、暫存與提交。
- 更新 `git-commit-script` 能力規格。

## Capabilities

### New Capabilities
- `git-commit-script`: 提供一鍵式 PowerShell 腳本以進行 `avd_vue` 專案的 Git 版本提交。

### Modified Capabilities

## Impact

- 新增 `c:\JohnLiang\..Project\commit_avd_vue.ps1` 腳本。
- 使用者與 Agent 均可透過執行此 `.ps1` 腳本完成版本提交。

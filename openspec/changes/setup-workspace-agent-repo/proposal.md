## Why

使用者在多台電腦之間切換開發時，需要同步通用的 AI 技能（`.agent/skills`、`.agent/workflows`）、OpenSpec 規範以及自動化輔助腳本。由於專案程式碼（如 `..Project/avd`）已有獨立的 Git Repo，因此需將 `C:\JohnLiang\` 建立為獨立的環境設定庫（Workspace Config Repo），並透過 `.gitignore` 嚴格隔離專案資料夾，避免巢狀 Git 衝突與大檔案污染。

## What Changes

- **建立工作區 `.gitignore`**：
  - 嚴格忽略專案原始碼目錄（如 `..Project/avd/` 及未來的任何子專案資料夾）。
  - 忽略大型檔案與暫存產物（`*.apk`, `*.msi`, `node_modules`, `dist`, `.vscode/` 等）。
  - 保證追蹤並同步 `.agent/`（技能與工作流）、`openspec/`、以及根目錄與 Project 層級的維護腳本。
- **初始化 Workspace Git 版本庫**：
  - 在 `C:\JohnLiang\` 初始化獨立 Git Repo 並建立初始 Commit。
- **建立工作區一鍵同步腳本**：
  - 提供 `commit_JohnLiang.ps1` 供使用者快速提交並推送 AI 技能與工作區設定至 GitHub 遠端倉庫。

## Capabilities

### New Capabilities
- `workspace-git-sync`: 建立工作區層級的 Git 版本控管機制、專屬 `.gitignore` 與自動化同步腳本，實現個人 AI 開發環境與技能庫的跨電腦無縫同步。

### Modified Capabilities
<!-- 無既有規格修改 -->

## Impact

- 影響範圍僅限 `C:\JohnLiang\` 工作區環境層級。
- 與現有 `..Project/avd` 專案完全解耦，不干擾子專案本身的獨立 Git 運作。

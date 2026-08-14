## Purpose

提供工作區層級的 Git 版本控管機制、專用 .gitignore 排除規則與提交腳本，使使用者能在多台電腦間同步 AI 技能（.agent/）、OpenSpec 規範與腳本，同時維持各子專案之獨立性。

## ADDED Requirements

### Requirement: Workspace Git Ignore Configuration
系統必須在 `C:\JohnLiang` 根目錄提供 `.gitignore` 設定檔，排除所有子專案目錄（如 `..Project/avd/`）、大型二進位檔案（`*.apk`, `*.msi`, `*.exe`, `*.zip`）與編譯暫存，同時確保追蹤 `.agent/` 與 `openspec/` 等 AI 技能與全域規範。

#### Scenario: Verify project directories and build artifacts are ignored
- **WHEN** 使用者在 `C:\JohnLiang` 執行 `git status`
- **THEN** `..Project/avd/` 與大型產物不得出現在未追蹤（Untracked）清單中

### Requirement: Workspace Git Sync Script Execution
系統必須在 `C:\JohnLiang` 根目錄提供 PowerShell 腳本 `commit_JohnLiang.ps1`，負責自動化檢查狀態、暫存變更、建立 Commit 並推送到 GitHub 工作區遠端倉庫。

#### Scenario: User runs commit_JohnLiang.ps1
- **WHEN** 使用者執行 `commit_JohnLiang.ps1`
- **THEN** 腳本必須完成 `C:\JohnLiang` 環境設定之暫存、提交並自動執行 `git push -u origin main`

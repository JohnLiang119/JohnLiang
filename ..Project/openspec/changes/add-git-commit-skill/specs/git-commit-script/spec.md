## Purpose

提供 `c:\JohnLiang\..Project` 層級之 PowerShell 自動化腳本，協助使用者或 Agent 進行 `avd` 專案的 Git 狀態確認、暫存、版本提交與自動推送至 GitHub 遠端倉庫。

## ADDED Requirements

### Requirement: PowerShell Git Commit Script Execution
The system MUST provide a PowerShell script `commit_avd.ps1` at `c:\JohnLiang\..Project`. The script SHALL check git status, prompt or accept a commit message in Traditional Chinese, execute `git commit`, and automatically `git push` to origin main.

#### Scenario: User runs commit_avd.ps1 script
- **WHEN** user executes `commit_avd.ps1` with a commit message parameter or prompt
- **THEN** system MUST perform `git status`, stage modified files, commit with the provided message, push to remote repository (`origin main`), and show status feedback.

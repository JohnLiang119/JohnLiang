## Context

參見 [proposal.md](file:///C:/JohnLiang/openspec/changes/add-workspace-sync-scripts/proposal.md)。工作區環境（`C:\JohnLiang`）與應用專案（`..Project/avd`）為雙 Repo 獨立管理架構。

## Goals / Non-Goals

**Goals:**
- 提供 `setup_JohnLiang.ps1`：專門處理新電腦的專案自動下載與環境還原。
- 提供 `pull_all.ps1`：專門處理日常切換電腦時的一鍵全自動更新（工作區 + 專案）。
- 所有腳本統一存為 **UTF-8 with BOM** 格式。

**Non-Goals:**
- 不修改既有的 `commit_avd.ps1` 與 `commit_JohnLiang.ps1` 提交邏輯。

## Decisions

### 1. `setup_JohnLiang.ps1`（情境一：新電腦初次設置）
- **流程邏輯**：
  1. **階段一（工作區環境檢測）**：檢查 `C:\JohnLiang` 是否存在；若不存在，自動執行 `git clone https://github.com/JohnLiang119/JohnLiang.git C:\JohnLiang`。
  2. **階段二（專案程式碼檢測）**：檢查 `C:\JohnLiang\..Project\avd` 是否已存在；若不存在，自動執行 `git clone https://github.com/JohnLiang119/avd.git C:\JohnLiang\..Project\avd`。
  3. **階段三（依賴自動還原）**：自動切換至 `C:\JohnLiang\..Project\avd` 並呼叫 `restore_avd.ps1` 完成套件安裝與資源同步。

### 2. `pull_all.ps1`（情境二：日常切換電腦更新）
- **流程邏輯**：
  1. **階段一（工作區同步）**：於 `C:\JohnLiang` 執行 `git pull`，同步最新 AI 技能與規範。
  2. **階段二（專案同步）**：檢查 `..Project/avd` 是否存在：
     - 若存在：切換至該目錄執行 `git pull`。
     - 若不存在：提示可先執行 `setup_JohnLiang.ps1`。

## Risks / Trade-offs

- **[Risk]** 本地有未提交修改時 `git pull` 可能發生衝突。
  - **Mitigation**：腳本在 pull 前檢查 `git status --porcelain`，若有未提交修改則提示使用者先執行 `commit`。

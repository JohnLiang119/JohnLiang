## Context

參見 [proposal.md](file:///C:/JohnLiang/openspec/changes/setup-workspace-agent-repo/proposal.md)。目前 `C:\JohnLiang\` 包含 `.agent/`（技能與工作流）、`openspec/`（全域與專案規範）、`..Project/` 及其維護腳本，以及子專案 `..Project/avd/`（擁有自身的 Git Repo）。

## Goals / Non-Goals

**Goals:**
- 在 `C:\JohnLiang\` 建立獨立的 Git 版本庫。
- 設定精確的 `.gitignore`，徹底排除子專案原始碼（`..Project/avd/`）、編譯產物（`*.apk`, `*.msi`, `dist/`, `build/`）與 `node_modules`。
- 提供 `commit_JohnLiang.ps1`（UTF-8 with BOM），支援自動檢查狀態、提交與推送到遠端 GitHub 倉庫。

**Non-Goals:**
- 不合併或修改 `..Project/avd` 現有的獨立 Git 倉庫。
- 不強制綁定特定的遠端倉庫名稱，提供彈性讓使用者設定 GitHub 遠端 URL。

## Decisions

### 1. 採用雙 Repo 隔離架構 (Dual-Repo Separation)
- **決定**：工作區環境（AI Skills / OpenSpec）與應用程式碼（`avd`）各自擁有獨立的 Git Repo。
- **替代方案**：MonoRepo（將所有專案硬塞進同一 Repo）——已被否決，因為會造成專案間耦合過深、大檔案污染且難以個別 release。
- **理由**：環境與專案解耦，換電腦時可分別 Clone/Pull，乾淨且靈活。

### 2. 精準的 `.gitignore` 規則
- **規則設計**：
  ```gitignore
  # 忽略所有專案目錄與其依賴
  ..Project/avd/
  ..Project/*/node_modules/
  **/node_modules/

  # 忽略大檔案與編譯產物
  *.apk
  *.msi
  *.exe
  *.zip
  dist/
  build/
  .vscode/
  .gemini/

  # 確保追蹤工作區核心
  !.agent/
  !openspec/
  !..Project/commit_avd.ps1
  !commit_JohnLiang.ps1
  ```

## Risks / Trade-offs

- **[Risk]** 遠端倉庫尚未在 GitHub 建立時執行 push 報錯。
  - **Mitigation**：在 `commit_JohnLiang.ps1` 中加入遠端倉庫存在檢測與友善指引提示。

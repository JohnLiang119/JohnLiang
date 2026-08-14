## Context

使用者要求不要透過 Skill，而是將 Git 提交流程撰寫為 PowerShell 腳本 (`commit_avd_vue.ps1`) 置於 `c:\JohnLiang\..Project` 目錄。

## Goals / Non-Goals

**Goals:**
- 在 `c:\JohnLiang\..Project\commit_avd_vue.ps1` 建立 PowerShell 腳本。
- 腳本支援接收提交訊息參數（`-Message`），若未提供則自動提示輸入。
- 執行內部 Git 狀態檢查、`git add` 與 `git commit`，並顯示提交成果。

**Non-Goals:**
- 自動修剪或刪除分支。

## Decisions

- **檔名與位置決策**：
  - 位置：`c:\JohnLiang\..Project\commit_avd_vue.ps1`
  - 編碼：UTF-8 with BOM (符合 `.ps1` 腳本全域規範)

## Risks / Trade-offs

- [Risk] 若未傳入 `-Message` 參數，非互動模式下可能需要預設提交訊息。
  - **Mitigation**: 腳本內建預設訊息機制與互動式 prompt 切換。

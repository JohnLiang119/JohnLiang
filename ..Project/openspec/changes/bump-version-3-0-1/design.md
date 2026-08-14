## Context

將 `avd_vue` 專案版本從 `3.0.0` 提升至 `3.0.1`，涉及多個跨平台組態檔的欄位更新。

## Goals / Non-Goals

**Goals:**
- 更新 `avd_vue/package.json` 中的 `version` 欄位為 `3.0.1`。
- 更新 `avd_vue/src-tauri/tauri.conf.json` 中的 `version` 欄位為 `3.0.1`。
- 更新 `avd_vue/src-tauri/Cargo.toml` 中的 `version` 欄位為 `3.0.1`。
- 更新 `avd_vue/android/app/build.gradle` 中的 `versionName` 欄位為 `"3.0.1"`。

**Non-Goals:**
- 不自動觸發 `all.ps1` 全平台編譯腳本（需由使用者手動執行）。

## Decisions

- **同步更新各平台組態檔**：
  - 確保開發環境與打包輸出（APK, MSI）呈現統一的 3.0.1 版號。

## Risks / Trade-offs

- [Risk] 若漏更換某個檔的版號可能造成編譯或安裝升級版本判定不符。
  - **Mitigation**: 在 tasks 中列出明確的各檔案清冊並逐一校對。

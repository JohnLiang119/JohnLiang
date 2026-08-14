## Why

將 `avd_vue` 專案升級版本至 `3.0.1`，明確版號變更並同步各平台的版本資訊檔。

## What Changes

- 將 `avd_vue/package.json` 中的 `version` 欄位更新為 `3.0.1`。
- 將 `avd_vue/src-tauri/tauri.conf.json` 中的 `version` 欄位更新為 `3.0.1`。
- 將 `avd_vue/src-tauri/Cargo.toml` 中的 `version` 欄位更新為 `3.0.1`。
- 將 `avd_vue/android/app/build.gradle` 中的 `versionName` 欄位更新為 `"3.0.1"`。

## Capabilities

### New Capabilities
- `version-release`: 控管專案版本發布與版號同步規格。

### Modified Capabilities

## Impact

- 影響 `package.json`、`tauri.conf.json`、`Cargo.toml` 與 `android/app/build.gradle` 的版號設定。

# 自動進版規範 (Auto Version Bumping Rule)

## 🔄 每次變更必須自動進版
- **執行時機**：無論是修復 BUG、新增功能、微調介面，只要有對專案原始碼進行修改，在完成該次任務時，**必須自動提升專案的版本號 (Patch Version)**（例如從 `1.0.44` 升級至 `1.0.45`），**無需等待使用者明確要求**。
- **修改範圍**：進版時，必須確保同步修改以下四個檔案，保持版本號一致：
  1. `package.json` (更新 `"version"`)
  2. `src-tauri/tauri.conf.json` (更新 `"version"`)
  3. `src-tauri/Cargo.toml` (更新 `version`)
  4. `android/app/build.gradle` (同步更新 `versionName`，並且**必須將 `versionCode` 的數值 +1**)

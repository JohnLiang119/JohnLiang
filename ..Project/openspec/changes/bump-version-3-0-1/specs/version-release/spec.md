## Purpose

定義專案版號升級與版本發布管理規格，確保前端、Windows Tauri 與 Android 組態檔之版號同步一致。

## ADDED Requirements

### Requirement: Application Version Alignment
The project SHALL align all application configuration version strings to `3.0.1`. The version fields in `package.json`, `tauri.conf.json`, `Cargo.toml`, and `build.gradle` MUST be updated to `3.0.1`.

#### Scenario: Verify version bump across configuration files
- **WHEN** version bump is executed for release `3.0.1`
- **THEN** system MUST show `3.0.1` in `package.json`, `tauri.conf.json`, `Cargo.toml`, and `android/app/build.gradle`

# project-rename 規格說明

## 規格目標
確保專案目錄名稱由 `avd_vue` 調整為 `avd` 後，專案各項配置與維護腳本皆能正常運作。

### Requirement: Directory Renaming
系統必須將專案資料夾重命名為 `avd`。

#### Scenario: Verify directory exists
- **WHEN** 檢查 `c:\JohnLiang\..Project\avd`
- **THEN** 該目錄必須存在且包含所有原始原始碼與 `.git` 版本庫

### Requirement: Script Renaming and Path Updates
維護腳本必須對應新專案名稱。

#### Scenario: Execute commit script
- **WHEN** 執行 `commit_avd.ps1`
- **THEN** 腳本正確定位至 `c:\JohnLiang\..Project\avd` 並執行 Git 操作

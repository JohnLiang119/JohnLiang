## 1. UI 與設定實作 (App.vue)

- [x] 1.1 在 `App.vue` 中的「偏好設定」Modal 增加一個 Switch 元件來控制「測試模式」。

## 2. 更新邏輯修改 (UpdateService.ts)

- [x] 2.1 在 `UpdateService.checkForUpdates` 中讀取 `localStorage` 的測試模式狀態。
- [x] 2.2 若測試模式開啟，改打 `https://api.github.com/repos/JohnLiang119/avd/releases` API 並取得第一筆最新結果。
- [x] 2.3 確認不論是否開啟測試模式，後續的版本比較與安裝檔擷取邏輯皆能正確運作。

## 3. 發布腳本調整 (release_avd.ps1)

- [x] 3.1 修改腳本，不要無條件附加 `--latest`。
- [x] 3.2 增加條件判斷：僅當「未傳入」 `-P` 參數時，才將 Release 標記為 `--latest`。

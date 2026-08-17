## Why

目前頻道的訂閱清單（包含追蹤哪些頻道 @handle 以及監聽設定）是儲存在前端的 `localStorage` 裡面。這會有一個潛在的風險：如果使用者清除了瀏覽器或系統的快取資料（例如使用 Android 的「清除快取/資料」或 PC 上的 CCleaner），這份辛苦建立的訂閱清單就會完全遺失。
為了提供更安全可靠的資料保存機制，我們需要將這些使用者自建的重要資料升級為實體檔案。即使快取被清空，只要檔案還在，資料就不會遺失。

## What Changes

- 在 Tauri (Rust 後端) 中引入 `tauri-plugin-store` 套件。
- 修改前端的資料存取邏輯，將頻道訂閱（`avd_monitored_channels`）與監控設定（`avd_monitor_config`）從原本的 `localStorage` 改為透過 Store API 寫入獨立的 `config.json` 實體檔案。

## Capabilities

### New Capabilities
- `store/subscriptions`: 定義使用 Tauri Store 以實體檔案保存頻道訂閱資料的能力。

### Modified Capabilities


## Impact

- `src/App.vue`: 讀取與寫入頻道資料的邏輯。
- `src-tauri/Cargo.toml` 和 `src-tauri/src/lib.rs` (或 `main.rs`): 引入並註冊 `tauri-plugin-store`。

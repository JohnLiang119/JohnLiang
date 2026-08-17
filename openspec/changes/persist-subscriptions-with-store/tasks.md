## 1. Tauri Backend Setup

- [x] 1.1 Run `npm run tauri plugin add store` to install the plugin to `package.json` and `Cargo.toml`.
- [x] 1.2 Verify `tauri-plugin-store` is registered in `src-tauri/src/lib.rs` (or `main.rs`) and compiles successfully.

## 2. Frontend Store Initialization

- [x] 2.1 In `src/App.vue` (and any other relevant service like `DownloadService.ts`), import `{ Store }` from `@tauri-apps/plugin-store`.
- [x] 2.2 Initialize the store instance targeting `config.json` (e.g., `const store = new Store('config.json');`).

## 3. Data Migration and Loading

- [x] 3.1 Write an `initStore()` async function to read `avd_monitored_channels` and `avd_monitor_config` from the Store.
- [x] 3.2 Add migration logic: if the Store returns `null` but `localStorage` contains data, load from `localStorage`, then immediately write it to the Store.
- [x] 3.3 Ensure the application state (e.g. `monitoredChannels`) waits for `initStore()` to finish before rendering or running background checks.

## 4. Frontend Write Operations

- [x] 4.1 Modify the Vue `watch` effects for `monitoredChannels` and `monitorConfig` to use `await store.set(key, val)` and `await store.save()` instead of `localStorage.setItem()`.
- [x] 4.2 Test adding and removing a channel in the UI to confirm changes are saved persistently.

## Context

Currently, `avd_monitored_channels` and `avd_monitor_config` are stored in `localStorage`. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Persist channel subscriptions in a physical file using Tauri Store API.
- Ensure seamless read/write from the Vue frontend.
- Migrate existing `localStorage` data for users.

**Non-Goals:**
- Implementing a robust database (SQLite) for these simple JSON objects.
- Migrating other lightweight settings (like Test Mode) to Tauri Store (they can remain in `localStorage` as they are non-critical).

## Decisions

### 1. Tauri Plugin Store
**Decision:** Use `tauri-plugin-store` to manage a `config.json` file in the app's AppData directory.
**Rationale:** The data structure is a simple JSON object/array. Using a full SQLite database is overkill. The Tauri Store plugin automatically handles file I/O, OS-specific AppData paths, and provides a simple key-value API to the frontend.
**Alternatives:** Manual `fs.writeTextFile` in Rust. This requires writing custom commands and handling serialization, which is reinventing the wheel compared to using the official plugin.

### 2. Migration
**Decision:** On startup, read from the Store. If the store is empty, but `localStorage` has data, migrate it to the Store.
**Rationale:** To prevent existing users from losing their current subscriptions when this update is released.

## Risks / Trade-offs

- **Risk:** Additional dependency on `tauri-plugin-store` increases build size slightly.
  - **Mitigation:** It's an official Tauri plugin with minimal footprint and highly optimized Rust implementation.

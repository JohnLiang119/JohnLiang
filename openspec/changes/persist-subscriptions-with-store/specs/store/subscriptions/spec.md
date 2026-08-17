## Purpose

Provides a persistent, file-backed storage mechanism for user channel subscriptions and configurations so that they survive application cache clearings.

## ADDED Requirements

### Requirement: Persistent Storage of Channel Subscriptions
The system SHALL store the user's monitored channels list and monitor configurations using Tauri Store instead of `localStorage`.

#### Scenario: App restart or cache clear
- **WHEN** the application starts or the browser cache is cleared
- **THEN** the system successfully reads the subscriptions from the local file system config instead of falling back to default empty values

### Requirement: Backward Compatibility (Migration)
The system SHALL migrate existing subscriptions from `localStorage` if they exist and the Store is currently empty.

#### Scenario: First boot after update
- **WHEN** a user who previously used `localStorage` updates the app and boots it for the first time
- **THEN** the system copies their existing `localStorage` data into the Tauri Store so no data is lost

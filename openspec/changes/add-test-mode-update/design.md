## Context

See proposal.md for motivation. The application currently relies on GitHub's `/releases/latest` API for fetching update information, which inherently filters out all "Pre-release" and "Draft" versions. The release script `release_avd.ps1` currently applies the `--latest` flag globally to all releases, which contradicts the concept of a pre-release in GitHub.

## Goals / Non-Goals

**Goals:**
- Provide a persistent local setting (Test Mode) to control update fetching behavior.
- Allow the application to fetch and prompt for Pre-release updates when Test Mode is active.
- Ensure the release script correctly issues Pre-releases without marking them as Latest.

**Non-Goals:**
- Modifying the actual download mechanism (`DownloadService` or Rust code).
- Supporting multiple release channels (e.g., Alpha, Beta, RC) beyond the simple Official vs. Pre-release distinction.
- Automating the toggle of Test Mode based on build configuration.

## Decisions

### 1. Persistent Storage for Test Mode
**Decision:** Use `localStorage` to store the `isTestModeEnabled` boolean flag.
**Rationale:** The App settings are currently lightweight. `localStorage` is simple, synchronous, and easily accessible across the Vue app and Services.
**Alternatives:** Storing it in Tauri's native `store` plugin. This is more robust but adds unnecessary complexity and dependencies for a simple toggle flag.

### 2. GitHub API Selection
**Decision:** When `isTestModeEnabled` is true, fetch `https://api.github.com/repos/JohnLiang119/avd/releases` and use the first item `[0]` (since it is sorted by date descending). When `isTestModeEnabled` is false, fetch `https://api.github.com/repos/JohnLiang119/avd/releases/latest`.
**Rationale:** The `/releases` endpoint returns a list of all releases (including pre-releases, but excluding drafts). The first element is effectively the newest release overall. This perfectly fulfills the need to check for pre-releases without complex pagination.
**Alternatives:** Always fetch `/releases` and filter client-side. This consumes slightly more data and is unnecessary when we only want the Latest release.

### 3. Release Script Logic
**Decision:** In `release_avd.ps1`, conditionally append the `--latest` flag only when `-P` is NOT specified.
**Rationale:** GitHub's `--latest` flag forces a release to become the primary "Latest" release, overriding the `releases/latest` API. Removing it for `-P` ensures the pre-release is successfully hidden from normal users.

## Risks / Trade-offs

- **Risk:** Rate limiting on the `/releases` endpoint might be different from `/releases/latest`.
  - **Mitigation:** GitHub API rate limits are generally per-IP and sufficient for startup checks. We maintain the 5000ms timeout.
- **Risk:** The latest release in `/releases` might be an older pre-release if an official release was published right after it but not tagged correctly.
  - **Mitigation:** GitHub sorts `/releases` by creation date, which is highly reliable for standard chronological release workflows.

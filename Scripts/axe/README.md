# Local UAT with `axe`

This folder is the **single source of truth** for browser-free, simulator-driven **User Acceptance** regression: what each scenario covers, which **`axe` batch** file drives it, which **launch arguments** apply, and what **artifacts** to expect.

Tracking: [issue #156](https://github.com/kipyin/grace-notes/issues/156).

## What is `axe`?

[**axe**](https://www.axe-cli.com/) (`brew install axe`) is a CLI that drives the iOS Simulator UI from the Mac. This repo uses **`axe batch`** (one step per line in a file) plus **`axe screenshot`** (and optionally **`axe record-video`**) from [`Scripts/uat_axe_run.sh`](../../Scripts/uat_axe_run.sh), invoked as **`make uat-axe`** from the repo root.

## Batch file rules

Files live under [`batch/`](batch/).

- Do **not** put `--udid` in the file; `uat_axe_run.sh` passes it on the `axe batch` command.
- Prefer `tap --label …` for controls with a stable **`AXLabel`**. **Main tabs (Today / Past / Settings)** do not appear in `axe describe-ui` on SwiftUI `TabView` (empty tab-bar group); batches use **fixed tap coordinates** for the iPhone 17 Pro–class layout (**402×874** pt): **Today** ~`(67, 832)`, **Past** ~`(201, 832)`, **Settings** ~`(310, 832)` (hit frames vary slightly by OS; re-measure with trial taps if a tab stops switching). If your `DESTINATION` resolution differs, adjust the `tap -x -y` lines under [`batch/`](batch/).
- Use `sleep` steps so SwiftUI transitions, sheets, and saves can finish.
- For brittle controls, prefer `tap --id …` when the app exposes a stable **accessibility identifier** (see [`JournalScreen`](../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift) and [`JournalUITests`](../../GraceNotesUITests/JournalUITests.swift)).

## `make uat-axe` (no CI)

- **Build:** **GraceNotes (UAT)** scheme, **UAT** configuration (`USE_UAT_DATABASE`, seeded on-disk store). Not part of GitHub Actions.
- **Driver:** [`Scripts/uat_axe_run.sh`](../../Scripts/uat_axe_run.sh) — boot simulator, `xcodebuild build`, `simctl install`, fifteen numbered steps (batches + PNGs).
- **Artifacts:** PNGs under `build/uat-captures/<timestamp>/` (gitignored). **Every** phase produces at least one PNG after its batch.
- **Onboarding / tab bar / locale:** For plain UAT launches, [`uat_axe_run.sh`](../../Scripts/uat_axe_run.sh) passes **`-AppleLanguages` `(en)`**, **`-AppleLocale` `en_US`**, **`-grace-notes-uat-fast-onboarding`**, and **`-grace-notes-uat-mark-post-seed-journey-seen`** so English **`--label`** taps match `Localizable.xcstrings`, the tab bar is available, and the seeded-data post-Seed journey does not cover it (see `GraceNotesApp` init). **UAT-09** runs **last** and validates a **fresh install** (uninstall/reinstall). After UAT-09, the script reinstalls the same `.app` so a follow-up **`make run-uat`** is not broken.

## MP4 (supplemental motion capture)

Still images are the default pass/fail signal. **MP4** helps for scrolls, onboarding, share sheets, and debugging flakes.

Controlled by **`UAT_AXE_MP4`** when running the script (see [`uat_axe_run.sh`](../../Scripts/uat_axe_run.sh)):

| Value | Behavior |
|--------|----------|
| *(default)* | Records **UAT-07, UAT-09, UAT-10, UAT-12** during batch + screenshot for that phase |
| `0` / `no` / `off` | Skip all MP4 |
| `all` | Record every phase |
| `07,12` | Comma-separated two-digit phase IDs |

MP4 is **supplemental evidence**; exit **0** requires successful batches and **PNGs** unless you change that policy locally.

## Run order (driver)

The script runs phases in this order (UAT-09 is **last** so earlier steps keep seeded/onboarded state):

1. **UAT-01 → UAT-04** — Plain launch (seeded `Uat.store`), tabs and Today.
2. **UAT-05** — UITest launch bundle (ephemeral UI-test store; smoke parity).
3. **UAT-06** — Plain launch; persistence after kill + relaunch.
4. **UAT-07** — UITest bundle + wide review rhythm flag.
5. **UAT-08** — Plain launch; Past / recurring-style coverage on seed data.
6. **UAT-10** — Plain launch + **post-seed journey** UAT flag.
7. **UAT-11** — UITest bundle; structured journal / chips.
8. **UAT-12** — Plain launch; share sheet.
9. **UAT-13** — Plain launch; import/export settings.
10. **UAT-14** — Plain launch; reminders settings.
11. **UAT-15** — **Unlock Summer** UAT flag; appearance / Bloom toggle.
12. **UAT-09** — Uninstall, reinstall, **fast onboarding** UAT flag; fresh-install path.

## UAT scenarios (full table)

| ID | Goal | Launch / setup | UITest reference | `axe` batch | Artifacts | Manual glance |
|----|------|----------------|------------------|-------------|-----------|----------------|
| UAT-01 | **Today** after launch | Plain `simctl launch` (seeded UAT store) | [`GraceNotesSmokeUITests`](../../GraceNotesUITests/GraceNotesSmokeUITests.swift) `testSmokeLaunch` *(Debug + UITest store; different persistence path than UAT-01)* | [`batch/01_today_after_launch.txt`](batch/01_today_after_launch.txt) | PNG | Share visible; journal sections present |
| UAT-02 | **Past** tab | Plain | [`JournalUITests`](../../GraceNotesUITests/JournalUITests.swift) `test_reviewScreen_rhythmDrillInOpensJournalWithShare` | [`batch/02_navigate_past.txt`](batch/02_navigate_past.txt) | PNG | Insights / history load |
| UAT-03 | **Settings** | Plain | Settings UI tests as added | [`batch/03_navigate_settings.txt`](batch/03_navigate_settings.txt) | PNG | List readable |
| UAT-04 | Return to **Today** | Plain | — | [`batch/04_return_today.txt`](batch/04_return_today.txt) | PNG | Tabs switch cleanly |
| UAT-05 | **UI-test smoke** parity | **UITest args** (see below) — uses **UI-test SwiftData path**, not `Uat.store` | `GraceNotesSmokeUITests.testSmokeLaunch` | [`batch/05_uitest_smoke_share.txt`](batch/05_uitest_smoke_share.txt) | PNG; **MP4** default off for 05 | Share within timeout |
| UAT-06 | **Persistence** after relaunch | Plain UAT (seeded disk store); batch types → terminate → relaunch | [`JournalUITests`](../../GraceNotesUITests/JournalUITests.swift) `test_todayScreen_persistsJournalInputAcrossRelaunch` | [`batch/06_persistence_gratitude.txt`](batch/06_persistence_gratitude.txt) | PNG | Distinct line survives relaunch |
| UAT-07 | **Review rhythm** wide strip | UITest args + `-grace-notes-uitest-wide-review-rhythm` | [`JournalReviewRhythmScrollUITests`](../../GraceNotesUITests/JournalReviewRhythmScrollUITests.swift) | [`batch/07_review_wide_rhythm.txt`](batch/07_review_wide_rhythm.txt) | PNG; **MP4** default **on** | Horizontal rhythm scrolls |
| UAT-08 | **Past** / recurring-style cards | Plain (seed data) | — | [`batch/08_past_recurring_cards.txt`](batch/08_past_recurring_cards.txt) | PNG | Cards and browse sane |
| UAT-09 | **Onboarding** first open | **Last** in suite: uninstall, reinstall, **`-grace-notes-uat-fast-onboarding`** | — | [`batch/09_fresh_install_today.txt`](batch/09_fresh_install_today.txt) | PNG; **MP4** default **on** | Fresh path bounded |
| UAT-10 | **Post-seed / app tour** | Plain + **`-grace-notes-uat-post-seed`** | PostSeed journey / [`JournalScreen`](../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift) | [`batch/10_post_seed_journey.txt`](batch/10_post_seed_journey.txt) | PNG; **MP4** default **on** | Tour surfaces deterministically |
| UAT-11 | **Structured journal** | UITest args (reset store) | `JournalUITests` gratitude / need / person flows | [`batch/11_structured_journal_chips.txt`](batch/11_structured_journal_chips.txt) | PNG | Strips / completion update |
| UAT-12 | **Share** sheet | Plain | Smoke + journal tests (Share id) | [`batch/12_share_sheet.txt`](batch/12_share_sheet.txt) | PNG; **MP4** default **on** | Sheet presents; dismiss stable |
| UAT-13 | **Export / import** | Plain | — | [`batch/13_import_export_settings.txt`](batch/13_import_export_settings.txt) | PNG | Import/export screen stable |
| UAT-14 | **Reminders** | Plain | — | [`batch/14_reminders_settings.txt`](batch/14_reminders_settings.txt) | PNG | Toggle + copy stable |
| UAT-15 | **Appearance** / Bloom | Plain + **`-grace-notes-uat-unlock-summer-toggle`** | — | [`batch/15_appearance_bloom_toggle.txt`](batch/15_appearance_bloom_toggle.txt) | PNG | Summer toggle reachable |

## Launch arguments

### UITest parity bundle (`simctl launch`)

Used for **UAT-05, UAT-07, UAT-11**. Matches [`configureGraceNotesUITestLaunch`](../../GraceNotesUITests/XCUIApplication+GraceNotesUITestLaunch.swift) (and the array in [`uat_axe_run.sh`](../../Scripts/uat_axe_run.sh)):

- `-ui-testing`
- `-grace-notes-uitest-short-autosave`
- `-AppleLanguages` `(en)`
- `-AppleLocale` `en_US`
- `-grace-notes-reset-uitest-store`

**Plus** for **UAT-07** only:

- `-grace-notes-uitest-wide-review-rhythm`

Constants for the wide-rhythm flag live in [`ProcessInfo+GraceNotesUITesting.swift`](../../GraceNotes/GraceNotes/Application/ProcessInfo+GraceNotesUITesting.swift).

### Plain UAT locale (`simctl launch`)

**`uat_axe_run.sh`** also passes **`-AppleLanguages` `(en)`** and **`-AppleLocale` `en_US`** on plain (non–UI-test) launches so `axe` batch **`--label`** strings match the English table in batch files, independent of the simulator’s preferred language.

### UAT-only flags (`simctl launch`)

Read in the same `ProcessInfo` extension; **inert unless passed** (local capture / debugging only):

| Argument | Purpose |
|----------|---------|
| `-grace-notes-uat-fast-onboarding` | **Plain UAT + UAT-09:** skip first-run welcome so the tab bar is available (see `GraceNotesApp`) |
| `-grace-notes-uat-mark-post-seed-journey-seen` | **Plain UAT:** mark post-Seed journey seen so auto presentation does not cover tabs; **UAT-10** still uses `-grace-notes-uat-post-seed` to show it |
| `-grace-notes-uat-post-seed` | **UAT-10:** present post-seed full-screen journey on Today |
| `-grace-notes-uat-unlock-summer-toggle` | **UAT-15:** show Bloom (Summer) appearance toggle without real first-harvest progress |

### When adding launch flags

1. Add the constant / behavior in **`ProcessInfo+GraceNotesUITesting.swift`** (or the UITest extension if shared with XCTest only).
2. If **`make uat-axe`** should use it, update **[`Scripts/uat_axe_run.sh`](../../Scripts/uat_axe_run.sh)** and this **Launch arguments** section.
3. Add or extend a file under **`batch/`** if humans should reproduce the same UI state with `axe`.

## Troubleshooting

- If a `tap` target drifts, run `axe describe-ui --udid <udid>` against the booted simulator and adjust `--label` / `--id` in the batch file; note findings here or in the PR.
- `axe batch` supports `--wait-timeout` / `--poll-interval`; the driver uses **`--wait-timeout 25`** by default.

## Related paths

| Area | Path (from repo root) |
|------|-------------------------|
| Driver | `Scripts/uat_axe_run.sh` |
| Makefile entry | `make uat-axe`, `make run-uat` |
| UAT app flags (Swift) | `GraceNotes/GraceNotes/Application/ProcessInfo+GraceNotesUITesting.swift` |

# UAT scenarios (human + local `axe`)

Tracking: [issue #156](https://github.com/kipyin/grace-notes/issues/156).

Single source of truth for **boring regression** paths: shared setup hints for **manual** passes and **`axe`**, plus links to **UI tests** so launch args and flows don’t drift.

- **No GitHub Actions** — run on a Mac with Xcode, Simulator, and **axe** (`brew install axe`).
- **Primary automation entrypoint:** `make uat-axe` from the repo root (builds **GraceNotes (Demo)**, installs, runs batches under [`Scripts/axe/batch`](../../Scripts/axe/batch), writes PNGs to `build/uat-captures/<timestamp>/`).
- **Simulator onboarding:** The Demo capture script expects the **main tab bar** (Today / Past / Settings). On a **new** simulator, open the app once and complete first-run onboarding before relying on tab `tap --label` steps.

Optional MP4: after booting the same simulator, `axe record-video --help` documents recording; keep clips local (under `build/` they stay gitignored).

| ID | Goal | Setup | UITest reference | axe batch | Artifact | Manual glance |
|----|------|--------|------------------|-----------|----------|---------------|
| UAT-01 | Demo **Today** after launch | `make uat-axe` (installs Demo) or `make run-demo`; English locale | [`GraceNotesSmokeUITests.swift`](../../GraceNotesUITests/GraceNotesSmokeUITests.swift) `testSmokeLaunch` (Debug scheme + UITest store) | [`01_today_after_launch.txt`](../../Scripts/axe/batch/01_today_after_launch.txt) | PNG | Share visible; journal sections present; demo seed if store not empty |
| UAT-02 | Demo **Past** tab | Same as UAT-01 | [`JournalUITests.swift`](../../GraceNotesUITests/JournalUITests.swift) `test_reviewScreen_rhythmDrillInOpensJournalWithShare` (Past tab + rhythm) | [`02_navigate_past.txt`](../../Scripts/axe/batch/02_navigate_past.txt) | PNG | Insights / history load; no blank root; scroll feels sane |
| UAT-03 | Demo **Settings** | Same | Various settings UI tests as added | [`03_navigate_settings.txt`](../../Scripts/axe/batch/03_navigate_settings.txt) | PNG | Settings list readable; no overlap with tab bar |
| UAT-04 | Return to **Today** | Same | — | [`04_return_today.txt`](../../Scripts/axe/batch/04_return_today.txt) | PNG | Tabs still switch cleanly |
| UAT-05 | UITest **smoke** parity | `make test` / `test-ui-smoke` — not Demo | `GraceNotesSmokeUITests.testSmokeLaunch` | TBD (axe against non-Demo needs scripted install of Debug build) | PNG optional | Matches smoke: Share appears within timeout |
| UAT-06 | **Persistence** after relaunch | UITest `-grace-notes-reset-uitest-store` off after first run | [`JournalUITests.swift`](../../GraceNotesUITests/JournalUITests.swift) `test_todayScreen_persistsJournalInputAcrossRelaunch` | TBD | PNG optional | User-added line survives kill + relaunch |
| UAT-07 | **Review rhythm** wide strip | Launch with `-grace-notes-uitest-wide-review-rhythm` (+ UITest infra) | [`JournalReviewRhythmScrollUITests.swift`](../../GraceNotesUITests/JournalReviewRhythmScrollUITests.swift) | TBD | PNG / MP4 | Horizontal rhythm scrolls; columns tappable |
| UAT-08 | **Most recurring** / Past cards | Demo seed or UITest data | — (extend when a dedicated UITest lands) | TBD | PNG | Card copy; browse affordances if seeded |
| UAT-09 | **Onboarding** first open | Fresh simulator OR reset app data | — | TBD | MP4 friendly | Welcome + first journal path; no dead ends |
| UAT-10 | **Post-seed / app tour** | Reach Sprout milestone (see README terminology) | — | TBD | MP4 friendly | Tour surfaces only when expected; Settings continuation |
| UAT-11 | **Structured journal** entry flow | UITest launch with reset store | `JournalUITests` gratitude/need/person flows | TBD | PNG optional | Add line → strip appears; completion tier updates |
| UAT-12 | **Share** control | Today | Smoke + journal tests touch Share id | TBD | PNG | Share sheet attaches; card preview sane |
| UAT-13 | **Export / import** (Settings) | Navigate Settings → data trust | — | TBD | PNG | Copy explains privacy; export succeeds on device |
| UAT-14 | **Reminders** opt-in | Settings + notification permission path | — | TBD | PNG | Toggle state and helper copy |
| UAT-15 | **Appearance** (e.g. Summer / standard) | Settings or appearance toggle | — | TBD | PNG | Tabs and Past stay visually coherent |

## Launch arguments (UI tests)

Consolidated in [`ProcessInfo+GraceNotesUITesting.swift`](../GraceNotes/Application/ProcessInfo+GraceNotesUITesting.swift) and [`XCUIApplication+GraceNotesUITestLaunch.swift`](../../GraceNotesUITests/XCUIApplication+GraceNotesUITestLaunch.swift), including `-ui-testing`, `-grace-notes-reset-uitest-store`, `-grace-notes-uitest-wide-review-rhythm`, `-grace-notes-uitest-short-autosave`.

When adding a new UITest-only flag, update **this table** and add or extend a batch file under `Scripts/axe/batch/` if humans should reproduce the same state.

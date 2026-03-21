# App startup flow

This page follows the real startup call path.

Use this page to answer:
- What happens before the first screen appears?
- Where does startup failure handling live?

## Start point

File: `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`  
Type: `GraceNotesApp`

`@main` marks this as app entry.

## Startup phases

`GraceNotesApp` holds a `StartupCoordinator`.

Coordinator phases:

- `.loading`
- `.reassurance`
- `.retryableFailure(message:)`
- `.ready(PersistenceController)`

File: `../../GraceNotes/GraceNotes/Application/StartupCoordinator.swift`

## What happens on launch

1. `GraceNotesApp.init()` checks test flags.
2. In normal app mode, `startupCoordinator.startIfNeeded()` runs.
3. Coordinator calls `PersistenceController.makeForStartup()`.
4. While waiting, UI shows `StartupLoadingView`.
5. On success, phase changes to `.ready`.
6. App shows onboarding or main tabs.

## What StartupCoordinator adds

`StartupCoordinator` is useful because it centralizes:

- retry behavior
- message rotation while loading
- reassurance delay state
- failure message mapping

Without it, this logic would spread across views.

## Persistence boot

Persistence setup is in:

- `../../GraceNotes/GraceNotes/Data/Persistence/SwiftData/PersistenceController.swift`

Key points:

- Reads iCloud sync preference from `UserDefaults`.
- Tries to build a SwiftData `ModelContainer`.
- If cloud setup fails during startup, it can fall back to local-only disk store.

The runtime result is recorded in `PersistenceRuntimeSnapshot`.
That later helps Settings show honest storage status.

## After ready

`GraceNotesApp.readyContent` chooses:

- `OnboardingScreen` when `hasCompletedOnboarding` is false
- `TabView` when onboarding is done

Tabs:

- Today (`JournalScreen`)
- Review (`ReviewScreen`)
- Settings (`SettingsScreen`)

## UI test-specific path

There is special bootstrap logic for UI test sessions in `GraceNotesApp.init()`.

It can use `PersistenceController.makeForUITesting()`.

That seeds predictable data for tests.

## Common confusion

- “Why does app start with loading UI?”  
  Because persistence setup is async and can fail/retry.

- “Why separate UI-test startup path?”  
  To keep UI tests stable with known seeded data.

- “Is onboarding shown every time?”  
  No. It depends on `@AppStorage("hasCompletedOnboarding")`.

## If you know Python

`StartupCoordinator` is like a small state machine object.

It owns retry logic and phase transitions, instead of putting that logic in the view.

## Read next

- Next page: [12-data-and-swiftdata.md](./12-data-and-swiftdata.md)

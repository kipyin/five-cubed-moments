# Orientation

This page helps you get your bearings in this repo.

It covers:
- folder layout
- how to open the project
- where to start reading code

## 1) Folder layout

At repo root (`/workspace`), start here:

- `GraceNotes/` — app project folder  
  - contains `GraceNotes.xcodeproj`
  - contains the app source in `GraceNotes/GraceNotes/`
- `GraceNotesTests/` — unit tests
- `GraceNotesUITests/` — UI tests
- `docs/learning/` — this learning path

Inside `GraceNotes/GraceNotes/`, these are the main app layers:

- `Application/` — app entry and startup flow
- `Data/` — models, repository, persistence setup
- `Features/` — screen-level code (Journal, Settings, Onboarding)
- `Services/` — cross-feature logic (summarization, reminders)
- `DesignSystem/` — app theme and shared UI styles

## 2) How to open the project

Use macOS + Xcode 15+.

1. Open Xcode.
2. Open `GraceNotes/GraceNotes.xcodeproj`.
3. Select a scheme (`GraceNotes` or `GraceNotes (Demo)`).
4. Run with a simulator.

### Important platform truth

On Linux, you cannot run this iOS app.

You also cannot run `xcodebuild test` here.
That needs macOS + Xcode + iOS Simulator.

On Linux, you can still:
- read code
- read tests
- run `swiftlint lint`

## 3) Where to start reading code

Use this exact order first.

### Step A — App entry

File: `GraceNotes/GraceNotes/Application/GraceNotesApp.swift`  
Type: `GraceNotesApp`

Read:
- `init()` (startup setup)
- `body` (root view switching)
- `startupRootView`
- `readyContent`
- `mainTabView`

This shows how the app decides:
- loading screen vs ready screen
- onboarding vs main tabs

### Step B — Startup state machine

File: `GraceNotes/GraceNotes/Application/StartupCoordinator.swift`  
Type: `StartupCoordinator`

Read:
- `Phase` enum
- `startIfNeeded()`
- `beginStartupAttempt()`
- `handleStartupSuccess(...)`
- `handleStartupFailure(...)`

This is the startup lifecycle controller.

### Step C — Persistence bootstrap

File: `GraceNotes/GraceNotes/Data/Persistence/SwiftData/PersistenceController.swift`  
Type: `PersistenceController`

Read:
- `makeForStartup()`
- `makeController(inMemory:cloudSyncEnabled:)`
- cloud fallback path in `catch` block

This is where SwiftData container setup happens.

### Step D — Today screen

File: `GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`  
Type: `JournalScreen`

Read:
- section layout (Gratitudes, Needs, People in Mind)
- `.task` that triggers initial load
- calls into `JournalViewModel`

### Step E — Today screen logic

File: `GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`  
Type: `JournalViewModel`

Read:
- `loadTodayIfNeeded(using:)`
- `loadEntry(for:using:)`
- `persistChanges()`
- `completionLevel`

Then read:

File: `GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel+ChipEditing.swift`

This extension contains chip add/update/remove behavior.

### Step F — Repository reads

File: `GraceNotes/GraceNotes/Data/JournalRepository.swift`  
Type: `JournalRepository`

Read:
- `fetchAllEntries(context:)`
- `fetchEntry(for:context:)`
- `fetchEntry(dayStart:context:)`

This is the data query layer used by the ViewModel.

## 4) If you know Python

### `struct` vs `class`

Swift `struct` is a value type.  
Swift `class` is a reference type.

In this repo:
- `JournalItem` is a `struct` (`Data/Models/JournalItem.swift`)
- `JournalEntry` is a `class` with `@Model` (`Data/Models/JournalEntry.swift`)

### Optionals are like explicit `None`

`String?` or `[JournalItem]?` means value may be missing.  
You must unwrap before use.

In this repo:
- `JournalEntry.gratitudes` is `[JournalItem]?`
- many reads use `(entry.gratitudes ?? [])`

### Protocols are interface contracts

Similar to a Python abstract interface pattern.

In this repo:
- `Summarizer` protocol in `Services/Summarization/Summarizer.swift`
- implementations: `CloudSummarizer`, `DeterministicChipLabelSummarizer`

### `async/await` and `Task`

Similar idea to Python `asyncio`, but Swift uses structured concurrency.

In this repo:
- async summarize flow in `JournalViewModel+ChipEditing.swift`
- background startup work in `StartupCoordinator.swift`

## 5) What to read next

After this page, go back to [README](./README.md) and continue with the repo track.

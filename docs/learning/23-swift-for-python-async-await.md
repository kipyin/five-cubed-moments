# Swift for Python: async/await

This app uses async work in startup, summarization, reminders, and import/export.

## Startup async flow

`StartupCoordinator` starts async persistence setup:

- `persistenceFactory` is async
- startup task uses `Task { ... }`
- success/failure changes UI phase

File: `../../GraceNotes/GraceNotes/Application/StartupCoordinator.swift`

## Async summarization flow

`JournalViewModel+ChipEditing` uses async summarize calls.

Pattern:

1. immediate UI update
2. async summarize in background
3. apply result only if item still matches

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel+ChipEditing.swift`

## Async service calls

Examples:

- cloud summarization network call  
  `../../GraceNotes/GraceNotes/Services/Summarization/CloudSummarizer.swift`
- cloud review insights call  
  `../../GraceNotes/GraceNotes/Features/Journal/Services/CloudReviewInsightsGenerator.swift`

## Async reminder checks

`ReminderSettingsFlowModel` calls async scheduler methods:

- status refresh
- enable/disable
- reschedule

Files:

- `../../GraceNotes/GraceNotes/Features/Settings/ReminderSettingsFlowModel.swift`
- `../../GraceNotes/GraceNotes/Services/Reminders/ReminderScheduler.swift`

## Async in UI actions

`ImportExportSettingsScreen` wraps background work in `Task` and updates UI on main actor.

File: `../../GraceNotes/GraceNotes/Features/Settings/ImportExportSettingsScreen.swift`

## If you know Python

Conceptually close to `asyncio`:

- `await` waits for async result
- `Task` is a scheduled async unit

Main difference: Swift’s structured concurrency and actor rules are built into the language.

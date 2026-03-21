# Swift for Python: async/await

This app uses async work in startup, summarization, reminders, and import/export.

Read this page when async behavior feels hard to follow.

## Startup async flow

`StartupCoordinator` starts async persistence setup:

- `persistenceFactory` is async
- startup task uses `Task { ... }`
- success/failure changes UI phase

This is why startup screen can show loading, reassurance, retry, or ready.

Real snippet:

```swift
startupTask = Task { [weak self] in
```

```swift
let controller = try await persistenceFactory()
```

File: `../../GraceNotes/GraceNotes/Application/StartupCoordinator.swift`

## Async summarization flow

`JournalViewModel+ChipEditing` uses async summarize calls.

Pattern:

1. immediate UI update
2. async summarize in background
3. apply result only if item still matches

This guards against race conditions from quick edits.

Real snippet:

```swift
let result = await summarizeForChip(trimmed, section: .gratitude)
```

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel+ChipEditing.swift`

## Async service calls

Examples:

- cloud summarization network call  
  `../../GraceNotes/GraceNotes/Services/Summarization/CloudSummarizer.swift`
- cloud review insights call  
  `../../GraceNotes/GraceNotes/Features/Journal/Services/CloudReviewInsightsGenerator.swift`

Both services use async network requests with fallback/error handling.

Real snippet:

```swift
let (data, response) = try await urlSession.data(for: request)
```

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

This file is a good example of:
- running heavier work away from UI thread
- returning to main actor for UI state updates

Real snippet:

```swift
let fileURL = try await Task.detached(priority: .userInitiated) {
```

## If you know Python

Conceptually close to `asyncio`:

- `await` waits for async result
- `Task` is a scheduled async unit

Main difference: Swift’s structured concurrency and actor rules are built into the language.

## Common confusion

- “Why `Task` inside view code?”  
  To launch async work from UI events/lifecycle.

- “Why check if item still matches before update?”  
  Because async result may arrive after user changed/deleted item.

- “Can I ignore MainActor concerns?”  
  No. UI state updates should happen on main actor.

## Read next

- Next page: [24-swift-for-python-error-handling.md](./24-swift-for-python-error-handling.md)

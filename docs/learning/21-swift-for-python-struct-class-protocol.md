# Swift for Python: struct, class, protocol

This app uses all three heavily.

## `struct` in this repo

Use `struct` for value-like data.

Examples:

- `JournalItem`  
  File: `../../GraceNotes/GraceNotes/Data/Models/JournalItem.swift`
- `JournalExportPayload`  
  File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`
- `ReviewInsightsProvider`  
  File: `../../GraceNotes/GraceNotes/Features/Journal/Services/ReviewInsightsProvider.swift`

Why this is useful:

- copied by value
- simple data flow
- easier local reasoning

## `class` in this repo

Use `class` for shared mutable state or framework-required reference types.

Examples:

- `JournalEntry` (`@Model` class for persistence)
- `JournalViewModel` (`@Observable` class for UI state)
- `StartupCoordinator` (`ObservableObject`)

## Protocols in this repo

Protocols define behavior contracts.

Examples:

- `Summarizer` protocol  
  File: `../../GraceNotes/GraceNotes/Services/Summarization/Summarizer.swift`
- `ReviewInsightsGenerating` protocol  
  File: `../../GraceNotes/GraceNotes/Features/Journal/Services/ReviewInsights.swift`
- `ReminderScheduling` protocol  
  File: `../../GraceNotes/GraceNotes/Services/Reminders/ReminderScheduler.swift`

Implementations can change without changing call sites.

## If you know Python

You can think of protocols like typed interfaces.

They are stricter than Python duck typing, but great for test doubles and clear boundaries.

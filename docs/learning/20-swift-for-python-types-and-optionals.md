# Swift for Python: types and optionals

This page uses real examples from this repo.

## Strong types are everywhere

Swift code in this app is explicit about types.

Examples:

- `JournalCompletionLevel` enum  
  File: `../../GraceNotes/GraceNotes/Data/Models/JournalEntry.swift`
- `ReviewInsightSource` enum  
  File: `../../GraceNotes/GraceNotes/Features/Journal/Services/ReviewInsights.swift`
- `ReminderLiveStatus` enum  
  File: `../../GraceNotes/GraceNotes/Services/Reminders/ReminderScheduler.swift`

## Optionals (`?`) are explicit “maybe missing”

Python often uses `None` dynamically.

Swift uses optionals in the type itself.

Examples in this repo:

- `var gratitudes: [JournalItem]?` in `JournalEntry`
- `var completedAt: Date?` in `JournalEntry`
- `private(set) var saveErrorMessage: String?` in `JournalViewModel`

Common pattern you will see:

```swift
(entry.gratitudes ?? []).count
```

That means: use empty array when value is `nil`.

## `let` vs `var`

- `let` = immutable after set
- `var` = mutable

You can see both in almost every file.

## Value-returning helpers

Many methods return typed values instead of side effects only.

Examples:

- `completionLevel(...) -> JournalCompletionLevel`
- `exportSnapshot() -> JournalExportPayload`

## If you know Python

Swift forces “maybe None” handling at compile time.

That feels strict at first, but it removes many runtime null bugs.

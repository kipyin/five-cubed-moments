# Swift for Python: error handling

Swift uses `throw`, `try`, and `do/catch`.

This repo has many practical examples.

## Basic pattern in this app

Common shape:

```swift
do {
    // try work
} catch {
    // set user-facing message
}
```

## Example: journal save failure

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`

In `persistChanges()`:

- `try context.save()`
- on error sets `saveErrorMessage`

This gives a user-facing message instead of silent failure.

## Example: startup error to retry state

File: `../../GraceNotes/GraceNotes/Application/StartupCoordinator.swift`

`handleStartupFailure(...)` converts failure into:

- `.retryableFailure(message:)`

UI then shows retry action.

## Example: cloud fallback behavior

File: `../../GraceNotes/GraceNotes/Services/Summarization/CloudSummarizer.swift`

Cloud request failure does not crash flow.

It logs and falls back to deterministic summarizer.

## Example: import validation errors

File: `../../GraceNotes/GraceNotes/Features/Settings/Services/JournalDataImportService.swift`

Typed error enum:

- `JournalDataImportError`

Screen maps these to friendly messages:

- `ImportExportSettingsScreen.importFailureMessage(for:)`

## If you know Python

Swift error handling is explicit like typed exceptions.

You must mark throwing functions with `throws` and call them with `try`.

# Swift for Python: SwiftData basics in this repo

This page focuses on what this app actually uses.

## `@Model` persisted type

`JournalEntry` is declared with `@Model`.

File: `../../GraceNotes/GraceNotes/Data/Models/JournalEntry.swift`

This is the persisted row type for daily entries.

## Model container

`PersistenceController` creates `ModelContainer`.

File: `../../GraceNotes/GraceNotes/Data/Persistence/SwiftData/PersistenceController.swift`

Used for:

- startup disk store
- in-memory test store
- UI test store

## Model context

`ModelContext` is used for fetch/insert/save.

Examples:

- `JournalViewModel` writes via stored `modelContext`
- import/export screen creates background context from container

Files:

- `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`
- `../../GraceNotes/GraceNotes/Features/Settings/ImportExportSettingsScreen.swift`

## Fetching data

`FetchDescriptor<JournalEntry>` is used for queries.

Examples:

- `JournalRepository.fetchAllEntries(...)`
- `JournalRepository.fetchEntry(...)`

File: `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`

## View-level query

`ReviewScreen` uses `@Query` for reactive list data.

File: `../../GraceNotes/GraceNotes/Features/Journal/Views/ReviewScreen.swift`

## One practical pattern to notice

Repository fetches one-day entry by date range:

- `dayStart <= entryDate < nextDay`

That is a stable way to avoid time-of-day mismatch bugs.

## If you know Python

Think:

- `@Model` ~= ORM model class
- `ModelContext` ~= unit-of-work/session object

But this stack is local-first and integrated into SwiftUI app lifecycle.

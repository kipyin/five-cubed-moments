# JournalRepository guided tour

File: `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`  
Type: `JournalRepository`

This type is the data query layer for journal entries.

Keep this file in mind when debugging “wrong day” or “missing entry” issues.

## What it does

It has three public methods:

1. `fetchAllEntries(context:)`
2. `fetchEntry(for:context:)`
3. `fetchEntry(dayStart:context:)`

## Method details

### `fetchAllEntries(context:)`

- Returns entries sorted by `entryDate` descending.
- Used when a screen needs broader history data.

This is used in streak and review-related flows.

### `fetchEntry(for:context:)`

- Normalizes incoming date to start-of-day.
- Calls `fetchEntry(dayStart:context:)`.

This keeps date handling consistent for callers.

### `fetchEntry(dayStart:context:)`

- Uses range semantics:
  - `entry.entryDate >= dayStart`
  - `entry.entryDate < nextDay`
- Returns first matching entry for that day.

This range style matches other code paths (for example import/dedupe behavior).

It also avoids errors from comparing full timestamps directly.

## Where this repository is used

In `JournalViewModel`:

- load current or selected date entry
- refresh streak source entries

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`

Read these call sites:
- `loadEntry(for:using:)`
- `refreshStreakSummary()`

## Why this layer helps

Without `JournalRepository`, date query logic would spread across screens and view models.

Here, date fetch rules live in one place.

That reduces duplicated query predicates in screens.

## Common confusion

- “Why two fetchEntry methods?”  
  One is caller-friendly (`Date` input), one is normalized internal path (`dayStart`).

- “Why return optional entry?”  
  Missing day is valid; ViewModel may create new unsaved row.

- “Why not put this in ViewModel directly?”  
  Repository keeps data rules reusable and easier to test.

## If you know Python

This is close to a small DAO/repository class in Python.

It keeps query details out of UI logic.

## Read next

- Next page: [14-journal-ui-and-viewmodel.md](./14-journal-ui-and-viewmodel.md)

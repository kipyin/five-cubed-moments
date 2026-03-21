# JournalRepository guided tour

File: `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`  
Type: `JournalRepository`

This type is the data query layer for journal entries.

## What it does

It has three public methods:

1. `fetchAllEntries(context:)`
2. `fetchEntry(for:context:)`
3. `fetchEntry(dayStart:context:)`

## Method details

### `fetchAllEntries(context:)`

- Returns entries sorted by `entryDate` descending.
- Used when a screen needs broader history data.

### `fetchEntry(for:context:)`

- Normalizes incoming date to start-of-day.
- Calls `fetchEntry(dayStart:context:)`.

### `fetchEntry(dayStart:context:)`

- Uses range semantics:
  - `entry.entryDate >= dayStart`
  - `entry.entryDate < nextDay`
- Returns first matching entry for that day.

This range style matches other code paths (for example import/dedupe behavior).

## Where this repository is used

In `JournalViewModel`:

- load current or selected date entry
- refresh streak source entries

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`

## Why this layer helps

Without `JournalRepository`, date query logic would spread across screens and view models.

Here, date fetch rules live in one place.

## If you know Python

This is close to a small DAO/repository class in Python.

It keeps query details out of UI logic.

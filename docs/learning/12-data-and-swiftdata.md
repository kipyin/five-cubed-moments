# Data and SwiftData in this repo

This app stores journal entries locally with SwiftData.

## Core data types

### `JournalEntry` (`@Model`)

File: `../../GraceNotes/GraceNotes/Data/Models/JournalEntry.swift`

Important fields:

- `entryDate`
- `gratitudes`, `needs`, `people`
- `readingNotes`
- `reflections`
- `createdAt`, `updatedAt`, `completedAt`

Completion helpers are also here:

- `isComplete`
- `completionLevel`
- `criteriaMet(...)`

### `JournalItem` (`struct`)

File: `../../GraceNotes/GraceNotes/Data/Models/JournalItem.swift`

Represents one chip item:

- `fullText`
- `chipLabel`
- `isTruncated`
- `id`

`displayLabel` chooses `chipLabel` when present, else falls back to `fullText`.

## Persistence bootstrap

File: `../../GraceNotes/GraceNotes/Data/Persistence/SwiftData/PersistenceController.swift`

`PersistenceController` creates the `ModelContainer`.

It supports:

- normal startup
- in-memory testing
- UI testing store setup

It also tracks whether cloud sync was requested and whether startup used fallback.

That runtime state is carried by:

- `../../GraceNotes/GraceNotes/Data/Persistence/SwiftData/PersistenceRuntimeSnapshot.swift`

## Repository access

Query logic is in:

- `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`

The repository fetches:

- all entries
- one entry for a day (`[dayStart, nextDay)` range)

## Why chip arrays are optional in `JournalEntry`

`JournalEntry` uses optional arrays for chip lists.

The comment in the model explains why: CloudKit/Core Data compatibility during store load.

See comment near:

- `var gratitudes: [JournalItem]?`

## If you know Python

`@Model` is not like a plain dataclass.

It is a persisted model type managed by SwiftData.

So reads/writes happen through `ModelContext`, not just in-memory objects.

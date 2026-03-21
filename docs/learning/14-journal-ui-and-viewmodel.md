# Journal UI and ViewModel

This is the main feature flow in the app.

## Main screen

File: `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`  
Type: `JournalScreen`

Sections on screen:

- Gratitudes
- Needs
- People in Mind
- Reading Notes
- Reflections

The screen owns:

- local UI state (editing, focus, temporary input strings)
- a `JournalViewModel` for data and rules

## ViewModel responsibilities

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`  
Type: `JournalViewModel`

Main jobs:

- load entry for today/date
- create unsaved entry when missing
- autosave edits (debounced)
- compute completion level
- export share payload

The autosave trigger uses Combine debounce (`400ms`) before `persistChanges()`.

## Chip editing behavior

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel+ChipEditing.swift`

Pattern used:

1. Apply immediate chip update with interim label.
2. Run async summarize step.
3. Apply summarize result only if item still matches expected id/text.

This helps avoid stale async updates when user edits quickly.

UI-side helper functions are in:

- `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreenChipHandling.swift`

## Supporting views

- `SequentialSectionView` for chips + input row
- `ChipView` for each chip
- `EditableTextSection` for notes/reflections
- `DateSectionView` for completion badge and info card

Files:

- `../../GraceNotes/GraceNotes/Features/Journal/Views/SequentialSectionView.swift`
- `../../GraceNotes/GraceNotes/Features/Journal/Views/ChipView.swift`
- `../../GraceNotes/GraceNotes/Features/Journal/Views/EditableTextSection.swift`
- `../../GraceNotes/GraceNotes/Features/Journal/Views/DateSectionView.swift`

## If you know Python

Think of `JournalScreen` as the presentational layer.

Think of `JournalViewModel` as the state + behavior layer.

The split is similar to “UI component + view model/controller” in Python UI stacks.

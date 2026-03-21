# Tutorial 30: read the Today flow end to end

## Goal

Understand how one Today entry is loaded, edited, and saved.

No code changes in this tutorial.

You are building a clear mental model first.

## What you need first

- This repo checked out
- Basic Swift syntax comfort
- Optional: markdown notes to write what you find

You do **not** need Xcode for this tutorial.

Time estimate:
- 25 to 40 minutes

## Steps

1. Open `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`.
   - Find where `JournalScreen` is added to the Today tab.
2. Open `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`.
   - Find the `.task` block.
   - Note where it calls `loadTodayIfNeeded(using:)`.
3. Open `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`.
   - Read `loadTodayIfNeeded(using:)`.
   - Read `loadEntry(for:using:)`.
   - Read `persistChanges()`.
4. Open `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`.
   - Read `fetchEntry(for:context:)`.
   - Read `fetchEntry(dayStart:context:)`.
5. Return to `JournalViewModel+ChipEditing.swift`.
   - Read one add method (for example `addGratitude`).
   - Follow how it calls `scheduleAutosave()`.

6. Optional but useful:
   - open `../../GraceNotes/GraceNotes/Features/Journal/Views/SequentialSectionView.swift`
   - see how UI input routes into submit callbacks

## Real snippets to anchor each step

From app root:

```swift
NavigationStack {
    JournalScreen()
}
```

From `JournalScreen` load:

```swift
viewModel.loadTodayIfNeeded(using: modelContext)
```

From `JournalViewModel` autosave:

```swift
autosaveTrigger
    .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
```

From repository date range:

```swift
entry.entryDate >= dayStart && entry.entryDate < nextDay
```

## How to check it worked

Write a short call path in your own words.

You should be able to explain:

- where load starts
- where save happens
- how date-based fetch works
- where chip updates trigger autosave

If you can explain that clearly, this tutorial worked.

Example expected summary:

1. Today tab loads `JournalScreen`.
2. `JournalScreen` asks `JournalViewModel` to load today.
3. ViewModel fetches day entry via repository.
4. User edits fields/chips.
5. ViewModel debounces autosave and persists through `ModelContext`.

## What often goes wrong

- Reading view code only, but skipping ViewModel code.
- Missing that repository fetch uses a day range (`dayStart` to `nextDay`), not exact timestamp equality.
- Missing that chip editing has both immediate UI updates and async summarize steps.

If stuck:

- Go back to `JournalScreen` and find `.task` first.
- Then jump only to called function definitions.
- Avoid reading unrelated UI style code at this stage.

## Optional harder step

Trace the same flow for a **past date** opened from Review:

- start from `ReviewScreen`
- follow `NavigationLink` to `JournalScreen(entryDate:)`
- verify `loadEntry(for:using:)` path for non-today dates

Write 3 bullets on what is the same vs different between today and past-date flow.

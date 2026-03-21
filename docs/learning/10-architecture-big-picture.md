# Architecture: big picture

This app is split into clear layers.

That helps keep code calm and easy to change.

## Main layers

Source root: `GraceNotes/GraceNotes/`

- `Application/`  
  App entry and startup flow.
- `Data/`  
  Models, persistence, and repository queries.
- `Features/`  
  Screen-level UI and view logic.
- `Services/`  
  Shared logic (summarization, reminders).
- `DesignSystem/`  
  Colors, fonts, spacing, shared styles.

## Why this split is used here

This repo tries to keep boundaries explicit:

- Views render UI.
- ViewModels coordinate actions.
- Repositories fetch/write data.
- Services handle cross-cutting logic.

You can see this in:

- App entry: `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`
- Journal screen: `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`
- Journal ViewModel: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`
- Repository: `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`

## One real call path (Today tab)

1. `GraceNotesApp` builds `TabView`.
2. Today tab shows `JournalScreen`.
3. `JournalScreen` triggers `viewModel.loadTodayIfNeeded(using:)`.
4. `JournalViewModel` calls `JournalRepository.fetchEntry(...)`.
5. User edits text.
6. ViewModel schedules autosave and writes back through `ModelContext.save()`.

## Another real call path (Review insights)

1. Review tab shows `ReviewScreen`.
2. `ReviewScreen` asks `ReviewInsightsProvider` for insights.
3. Provider tries cloud insights when AI toggle is on and key is usable.
4. If cloud path fails, provider falls back to deterministic generator.

Files:

- `../../GraceNotes/GraceNotes/Features/Journal/Views/ReviewScreen.swift`
- `../../GraceNotes/GraceNotes/Features/Journal/Services/ReviewInsightsProvider.swift`

## If you know Python

Think in layers like this:

- SwiftUI `View` ~= Python web template/component layer
- ViewModel ~= controller/service object
- `JournalRepository` ~= data access object

But unlike many Python apps, this is a local iOS app with on-device persistence.

# Architecture: big picture

This app is split into clear layers.

That helps keep code calm and easy to change.

Use this page first to build a mental map.
Then details in later pages will make sense faster.

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

## Quick map of “who owns what”

- `Application/` decides what root UI is shown.
- `Features/` renders screens and user interactions.
- `Data/` owns persisted models and query rules.
- `Services/` handles shared logic used by features.
- `DesignSystem/` keeps look and feel consistent.

## Real snippet map (one-liners)

From app root:

```swift
@StateObject private var startupCoordinator: StartupCoordinator
```

File: `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`

From Today screen:

```swift
@State private var viewModel = JournalViewModel()
```

File: `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`

From ViewModel:

```swift
@ObservationIgnored private let repository: JournalRepository
```

File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`

From repository:

```swift
func fetchEntry(for date: Date, context: ModelContext) throws -> JournalEntry?
```

File: `../../GraceNotes/GraceNotes/Data/JournalRepository.swift`

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

In short:
- UI files should not carry data query rules.
- Data query rules should not be scattered across screens.

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

## Common confusion

- “Is ViewModel the same as repository?”  
  No. ViewModel coordinates UI state. Repository handles fetch rules.

- “Do Services always call network?”  
  No. Some services are local-only (for example deterministic summarization logic).

- “Is this strict MVVM?”  
  Not a textbook version. It is a practical split that keeps boundaries clear.

## If you know Python

Think in layers like this:

- SwiftUI `View` ~= Python web template/component layer
- ViewModel ~= controller/service object
- `JournalRepository` ~= data access object

But unlike many Python apps, this is a local iOS app with on-device persistence.

## Read next

- Next page: [11-app-startup-flow.md](./11-app-startup-flow.md)

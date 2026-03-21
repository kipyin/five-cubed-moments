# Swift for Python: state and property wrappers

SwiftUI uses property wrappers for state and environment wiring.

This repo has many good real examples.

## `@State`

Local view-owned mutable state.

Example:

- `JournalScreen` has many `@State` fields for input/editing/focus flow.
- File: `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`

## `@StateObject`

Owns lifecycle of reference-type observable models in a view.

Example:

- `GraceNotesApp` holds `@StateObject private var startupCoordinator`.
- File: `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`

## `@AppStorage`

Reads/writes `UserDefaults` with a property-like API.

Examples:

- onboarding completion flag in `GraceNotesApp`
- settings toggles in `SettingsScreen`

Files:

- `../../GraceNotes/GraceNotes/Application/GraceNotesApp.swift`
- `../../GraceNotes/GraceNotes/Features/Settings/SettingsScreen.swift`

## `@Environment`

Reads values provided by the environment.

Examples:

- `@Environment(\.modelContext)` in `JournalScreen`
- custom runtime snapshot environment in Settings

Files:

- `../../GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`
- `../../GraceNotes/GraceNotes/Application/PersistenceRuntimeSnapshotEnvironment.swift`

## `@Query`

SwiftData-backed query for views.

Example:

- `ReviewScreen` has `@Query(sort: \.entryDate, order: .reverse)`.
- File: `../../GraceNotes/GraceNotes/Features/Journal/Views/ReviewScreen.swift`

## `@Observable`

Observation macro for state models.

Example:

- `JournalViewModel` is `@Observable`.
- File: `../../GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift`

## If you know Python

Property wrappers are like declarative wiring tags.

They tell SwiftUI where state comes from and who owns it.

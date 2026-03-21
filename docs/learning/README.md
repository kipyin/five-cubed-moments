# Grace Notes learning path

This guide is for a Python developer who is new to Swift.

Goal:
- Understand this repo deeply.
- Learn Swift by reading real app code.
- Be ready to fix bugs and add small features.

How to use this guide:
- Read in order.
- Open the linked files as you read.
- Keep your own short notes.
- Try to explain each flow in your own words.

## Before you start

This app is iOS-only.

You need **macOS + Xcode 15+** to:
- build the app
- run the app in Simulator
- run unit tests and UI tests

On Linux, you can still do useful work:
- read code
- read tests
- run `swiftlint lint`

## A simple study rhythm

Use one page per session.

For each page:
1. Read the page once quickly.
2. Open every file link in that page.
3. Trace one call path end to end.
4. Write 3–5 bullet notes:
   - what starts the flow
   - where logic lives
   - where data is saved/read
5. Move to the next page only when this feels clear.

## Reading order

1. [01 Orientation](./01-orientation.md)
2. Repo track (10–19)
3. Swift track (20–25)
4. Tutorials (30–32)

---

## Repo track (how this app is built)

These pages explain app structure and feature call paths.

- [01-orientation.md](./01-orientation.md) — repo layout, opening in Xcode, first reading path
- [10-architecture-big-picture.md](./10-architecture-big-picture.md)
- [11-app-startup-flow.md](./11-app-startup-flow.md)
- [12-data-and-swiftdata.md](./12-data-and-swiftdata.md)
- [13-journal-repository.md](./13-journal-repository.md)
- [14-journal-ui-and-viewmodel.md](./14-journal-ui-and-viewmodel.md)
- [15-summarization.md](./15-summarization.md)
- [16-settings-import-export.md](./16-settings-import-export.md)
- [17-reminders.md](./17-reminders.md)
- [18-onboarding.md](./18-onboarding.md)
- [19-tests-and-mocks.md](./19-tests-and-mocks.md)

Main code we follow in this track:
- `GraceNotes/GraceNotes/Application/GraceNotesApp.swift` (`GraceNotesApp`)
- `GraceNotes/GraceNotes/Application/StartupCoordinator.swift` (`StartupCoordinator`)
- `GraceNotes/GraceNotes/Data/Persistence/SwiftData/PersistenceController.swift` (`PersistenceController`)
- `GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift` (`JournalScreen`)
- `GraceNotes/GraceNotes/Features/Journal/ViewModels/JournalViewModel.swift` (`JournalViewModel`)
- `GraceNotes/GraceNotes/Data/JournalRepository.swift` (`JournalRepository`)

What you should gain from this track:
- know where app startup decisions happen
- know where data model/query/persistence code lives
- know how Today, Review, and Settings flows connect
- know where to start when debugging a feature

---

## Swift track (learn Swift from this repo)

Each page teaches one Swift idea with real files from this app.

- [20-swift-for-python-types-and-optionals.md](./20-swift-for-python-types-and-optionals.md)
- [21-swift-for-python-struct-class-protocol.md](./21-swift-for-python-struct-class-protocol.md)
- [22-swift-for-python-state-and-property-wrappers.md](./22-swift-for-python-state-and-property-wrappers.md)
- [23-swift-for-python-async-await.md](./23-swift-for-python-async-await.md)
- [24-swift-for-python-error-handling.md](./24-swift-for-python-error-handling.md)
- [25-swift-for-python-swiftdata-basics.md](./25-swift-for-python-swiftdata-basics.md)

What you should gain from this track:
- read Swift optionals without getting stuck
- tell `struct` vs `class` usage in this repo
- understand property wrappers used in app code
- follow async flows in startup/network/save behavior

---

## Tutorials (small to larger tasks)

Each tutorial includes:
- goal
- what you need first
- steps
- how to check it worked
- common issues
- optional harder step

Tutorial pages:
- [30-tutorial-read-today-flow.md](./30-tutorial-read-today-flow.md)
- [31-tutorial-small-ui-copy-change.md](./31-tutorial-small-ui-copy-change.md)
- [32-tutorial-small-viewmodel-change-with-tests.md](./32-tutorial-small-viewmodel-change-with-tests.md)

How to pick tutorials:
- If you are on Linux, start with tutorial 30.
- If you have macOS + Xcode, do 30 -> 31 -> 32 in order.

---

## Notes for future updates

- Keep this index in sync with real files in `docs/learning/`.
- If code changes and a page becomes stale, add a short **needs update** note.
- Do not put real secrets in git (for example API keys).

## Quick troubleshooting while learning

- “I do not know where to start in code”  
  Go back to [01-orientation.md](./01-orientation.md), then read startup flow page 11.

- “I do not understand where save logic is”  
  Re-read page 14 and open `JournalViewModel.persistChanges()`.

- “I am confused by AI/summarization behavior”  
  Read page 15 and compare `SummarizerProvider` with `NaturalLanguageSummarizer`.

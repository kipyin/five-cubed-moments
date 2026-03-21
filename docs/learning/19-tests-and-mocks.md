# Tests and mocks

This repo has unit tests and UI tests.

## Test folders

- `../../GraceNotesTests/` — unit tests
- `../../GraceNotesUITests/` — UI tests

## Useful test doubles

Folder: `../../GraceNotesTests/TestDoubles/`

- `MockSummarizer.swift`
- `SpySummarizer.swift`
- `MockURLProtocol.swift`

These are used to:

- avoid real network calls
- count calls
- make behavior deterministic

## What is covered well

Examples:

- Journal view model behavior and limits
- review insight generators and policy
- import service validation and merge logic
- reminder scheduler + reminder settings model
- startup coordinator states

Browse:

- `../../GraceNotesTests/Features/Journal/`
- `../../GraceNotesTests/Features/Settings/`
- `../../GraceNotesTests/Services/Reminders/`
- `../../GraceNotesTests/Services/Summarization/`
- `../../GraceNotesTests/Application/StartupCoordinatorTests.swift`

## UI tests

File to start with:

- `../../GraceNotesUITests/JournalUITests.swift`

These tests launch the app and drive real UI interactions.

## Important caveats in current tests

You can see these in code comments and `XCTSkip` usage:

- some SwiftData tests skip on simulator due known crash conditions
- some timeline UI tests are intentionally skipped due simulator reliability issues

This is real project context, not test framework theory.

## Running tests

Requires macOS + Xcode.

From repo root (`/workspace`) on macOS:

- `make test` (default scheme tests)
- `make test-unit`
- `make test-ui`

Make targets are defined in:

- `../../Makefile`

## If you know Python

Think of this as:

- `pytest`-style unit tests for logic
- UI automation tests for integration/user flows

The test doubles are the same idea as mocks/stubs in Python testing.

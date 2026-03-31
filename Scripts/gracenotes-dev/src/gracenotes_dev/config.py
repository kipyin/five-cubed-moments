"""Repo-scoped defaults (migrated from the root Makefile)."""

from __future__ import annotations

# Xcode project and scheme
DEFAULT_PROJECT_RELATIVE = "GraceNotes/GraceNotes.xcodeproj"
DEFAULT_SCHEME = "GraceNotes"

# Default simulator destination (human / xcodebuild string)
DEFAULT_DESTINATION = "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest"

# CI pins (override if runtimes differ)
CI_SIMULATOR_PRO = "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest"
CI_SIMULATOR_XR = "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.5"

TEST_DESTINATION_MATRIX = "iPhone SE (3rd generation)@18.5;iPhone 17 Pro@latest"

ISOLATED_DERIVED_DATA = "/tmp/GraceNotes-TestDerivedData"

UNIT_TEST_BUNDLE = "GraceNotesTests"
UI_TEST_BUNDLE = "GraceNotesUITests"
SMOKE_UI_TEST = "GraceNotesUITests/GraceNotesSmokeUITests/testSmokeLaunch"

XCODE_TEST_FLAGS = ("-parallel-testing-enabled", "NO")

# iOS 17 hosted runtime can crash in these suites before assertions run.
LEGACY_RUNTIME_SKIP_FLAGS: tuple[str, ...] = (
    "-skip-testing:GraceNotesTests/DeterministicReviewInsightsTests",
    "-skip-testing:GraceNotesTests/HistoryEntryGroupingTests",
)

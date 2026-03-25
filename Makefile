PROJECT := GraceNotes/GraceNotes.xcodeproj
SCHEME := GraceNotes
DEMO_SCHEME := GraceNotes (Demo)
DESTINATION := platform=iOS Simulator,name=iPhone 17,OS=latest
ISOLATED_DERIVED_DATA := /tmp/GraceNotes-TestDerivedData
UNIT_TEST_BUNDLE := GraceNotesTests
UI_TEST_BUNDLE := GraceNotesUITests
XCODE_TEST_FLAGS := -parallel-testing-enabled NO
SIMULATOR_NAME := iPhone 17

.PHONY: help lint lint-preflight build test test-unit test-ui test-isolated test-demo test-demo-preflight test-demo-run test-all ci reset-simulators warmup-simulator

help:
	@echo "Available targets:"
	@echo "  make lint   - Run SwiftLint checks"
	@echo "  make build  - Build app (macOS + Xcode required)"
	@echo "  make test   - Run tests for default scheme (macOS + Xcode + iOS Simulator required)"
	@echo "  make test-unit - Run unit tests only for default scheme"
	@echo "  make test-ui   - Run UI tests only for default scheme"
	@echo "  make test-isolated - Run tests with isolated DerivedData to avoid Xcode contention"
	@echo "  make test-demo - Reset/warm simulators, then run tests for demo scheme"
	@echo "  make test-all  - Reset simulators between default/demo test runs"
	@echo "  make reset-simulators - Shutdown and erase all simulators"
	@echo "  make ci     - Run lint and full-suite tests with simulator resets"

lint:
	@$(MAKE) lint-preflight
	swiftlint lint

lint-preflight:
	@if ! command -v swiftlint >/dev/null 2>&1; then \
		echo "SwiftLint is not installed or not on PATH."; \
		echo "Install with Homebrew: brew install swiftlint"; \
		exit 1; \
	fi

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination '$(DESTINATION)' build

test:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination '$(DESTINATION)' $(XCODE_TEST_FLAGS) test

test-unit:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination '$(DESTINATION)' $(XCODE_TEST_FLAGS) -only-testing:"$(UNIT_TEST_BUNDLE)" test

test-ui:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination '$(DESTINATION)' $(XCODE_TEST_FLAGS) -only-testing:"$(UI_TEST_BUNDLE)" test

test-isolated:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination '$(DESTINATION)' $(XCODE_TEST_FLAGS) -derivedDataPath "$(ISOLATED_DERIVED_DATA)" test

test-demo:
	@$(MAKE) test-demo-preflight
	@$(MAKE) test-demo-run

test-demo-run:
	xcodebuild -project "$(PROJECT)" -scheme "$(DEMO_SCHEME)" -destination '$(DESTINATION)' $(XCODE_TEST_FLAGS) test

test-demo-preflight:
	@$(MAKE) reset-simulators
	@$(MAKE) warmup-simulator

reset-simulators:
	xcrun simctl shutdown all || true
	xcrun simctl erase all || true

warmup-simulator:
	@xcrun simctl boot "$(SIMULATOR_NAME)" >/dev/null 2>&1 || true
	@xcrun simctl bootstatus "$(SIMULATOR_NAME)" -b >/dev/null 2>&1 || true

test-all:
	$(MAKE) reset-simulators
	$(MAKE) test
	$(MAKE) reset-simulators
	$(MAKE) warmup-simulator
	$(MAKE) test-demo-run

ci:
	$(MAKE) lint
	$(MAKE) test-all

# `axe` batch files (local UAT)

These files are consumed by the Homebrew **axe** iOS Simulator CLI (`brew install axe`): one interaction step per line, passed to `axe batch --file …`.

- Do not put `--udid` in the file; the runner passes it on the `batch` command.
- Prefer `--label` for tab bar items when `accessibilityIdentifier` is not set (SwiftUI `Label` text in English locale).
- Use `sleep` pseudo-steps to allow SwiftUI transitions and journal saves to finish.

See the scenario table in [../../GraceNotes/docs/uat-scenarios.md](../../GraceNotes/docs/uat-scenarios.md).

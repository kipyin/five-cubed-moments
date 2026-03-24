---
initiative_id: 017-issue-40-80-insight-implementation
role: Test Lead
status: in_progress
updated_at: 2026-03-24
related_issue: 40
related_pr: none
---

# Testing

## Inputs Reviewed

- `GraceNotes/docs/agent-log/initiatives/017-issue-40-80-insight-implementation/brief.md`
- `GraceNotes/docs/agent-log/initiatives/017-issue-40-80-insight-implementation/architecture.md` (Phase A / **#40**, Phase B / **#80** close criteria)
- `GraceNotes/docs/agent-log/initiatives/017-issue-40-80-insight-implementation/design.md`
- `GraceNotes/GraceNotes/Features/Journal/Views/ReviewSummaryCard.swift`
- `GraceNotes/GraceNotes/Features/Journal/Views/ReviewScreen.swift`
- `GraceNotes/GraceNotes/Features/Journal/Services/WeeklyInsightCandidateBuilder.swift`
- `GraceNotes/GraceNotes/Features/Journal/Services/CloudReviewInsightsSanitizer.swift`
- `GraceNotes/GraceNotes/Features/Journal/Services/CloudReviewInsightsGenerator.swift`

## Risk Map

| Area | Risk | Why it matters |
|------|------|----------------|
| **Accessibility** | Wrong VoiceOver order or missing headers | Architecture requires meta → box 1 (incl. recurring) → box 2 → box 3; titles are headers. |
| **Dynamic Type** | Clipping, overflow, or unreadable caps at XL+ | Three stacked panels + line limits; small devices most sensitive. |
| **Thin / duplicate payload** | Identical text in two panels or empty boxes | `dedupedPanelBodies` must show distinct thin-week strings and non-empty Action. |
| **Localization** | Mismatched en / zh-Hans section labels | Keys: This week / A thread / A next step — parity with `Localizable.xcstrings`. |
| **#80 engine** | Cloud model ignores prompt; deterministic edge week | Sanitizer repairs duplicate Observation/Thinking; rule engine uses second insight or theme-bridge strings. |

## Test Strategy by Level

- **Unit:** `GraceNotesTests` — `DeterministicReviewInsightsGeneratorTests` (incl. `WeeklyInsightCandidateBuilder` narrative behavior), `CloudReviewInsightsGeneratorTests` (mocked API, duplicate-line repair, prompt strings).
- **Manual — Simulator or device (required for full Go):** Review tab → weekly insight with **On-device** and **AI** (when enabled and eligible); VoiceOver + largest practical Dynamic Type; zh-Hans spot check for new engine strings (`Localizable.xcstrings` entries for thread-bridge copy).
- **Optional smoke:** `CloudReviewInsightsLiveAPITests` (real network + API key) when validating cloud output quality.

## Execution Results

- **Static code review (2026-03-24):** `ReviewSummaryCard` matches **`design.md`**; **#80** changes keep v1 JSON keys; sanitizer adds parrot repair after resurfacing + narrative sanitize order.
- **Unit tests:** Maintainer should run on macOS:
  ```bash
  xcodebuild \
    -project GraceNotes/GraceNotes.xcodeproj \
    -scheme GraceNotes \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
    -only-testing:GraceNotesTests/DeterministicReviewInsightsGeneratorTests \
    -only-testing:GraceNotesTests/CloudReviewInsightsGeneratorTests \
    test
  ```
  (Adjust simulator name/OS to match `xcodebuild -scheme GraceNotes -showdestinations`.)

## Defects and Fixes

- None filed from static review.

## Coverage Adequacy Assessment

- **#40 UI:** Unchanged — VoiceOver row in `architecture.md` still needs device confirmation.
- **#80:** Core duplication paths covered by unit tests; live cloud tone remains subjective — use manual Review with AI on a dense week.

## Go/No-Go Testing Recommendation

**Conditional Go** — Proceed to QA when the focused `GraceNotesTests` classes above pass on macOS and **#40** manual checks (VoiceOver / Dynamic Type) are acceptable.

## Decision

Go/No-Go:

**Conditional** — Automated coverage updated for **#80**; full Go pending macOS test run + **#40** VoiceOver verification.

## Rationale

Engine behavior is validated primarily via **mocked** cloud responses and deterministic fixtures; Simulator confirms integration.

## Risks

- Live LLM output may still occasionally feel generic; sanitizer cannot fully correct all model failures without failing the quality gate.

## Open Questions

- None.

## Next Owner

**QA Reviewer** — Fill **`qa.md`** (Pass/Fail vs architecture **#40** + **#80**) after local `GraceNotesTests` run; then **Release Manager** for **`release.md`** and **018** lane alignment.

# Sticky completion badge expand/collapse (issue #235) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the sticky journal completion toolbar chip **icon-only by default**, **expand to icon + label on tap**, then **auto-collapse after 3 seconds of idle** or when the user **taps the expanded chip again**, without changing completion ranking logic or moving the badge out of the toolbar.

**Architecture:** Keep `JournalCompletionBarChip` as the visual control but add a **collapsed vs expanded** presentation (title text hidden + tighter horizontal padding when collapsed). Track expansion in `JournalScreen` (`@State` + `Task` auto-collapse) so scroll and toolbar visibility can reset expansion. **Tap routing:** collapsed tap expands and starts the timer; expanded tap collapses (issue “explicit dismiss”). Because the inline header pill is hidden while the sticky chip shows, **long-press** (and a VoiceOver custom action with the same handler) must preserve **completion info** (`JournalCompletionInfoPresentation.completionBadgeTapped`) so users can still open the meaning card from the toolbar. **Scroll (default assumption):** while expanded, **significant scroll movement** restarts the 3s idle timer (same spirit as unlock-toast scroll dismiss threshold)—does **not** force immediate collapse. **When the sticky bar hides** (scroll back to top), reset expansion so the next reveal starts collapsed.

**Tech Stack:** SwiftUI, existing `JournalScreen` / `JournalCompletionBarChip` / `JournalCompletionInfoPresentation`, `Localizable.xcstrings`, SwiftLint, Simulator manual verification (`grace test` on macOS where available).

**Tracked issue:** [kipyin/grace-notes#235](https://github.com/kipyin/grace-notes/issues/235)

---

## Execution with Cursor `agent` (spawn and watch subagents)

Use the **Cursor Agent CLI** (`agent`) from a shell to run **one plan task per process** (isolated context, easy to parallelize). Install/update: `agent update`. Authenticate once: `agent login`.

**Baseline (repo root, headless, trust workspace):**

```bash
cd /Users/kip/Code/grace-notes
agent --workspace /Users/kip/Code/grace-notes --print --trust \
  "Read docs/superpowers/plans/2026-04-08-sticky-completion-badge-235.md. Complete ONLY Task N (replace N). Match existing Swift style. Run: swiftlint lint. Commit with a focused message referencing #235. Summarize files changed."
```

**Watch output live (stream JSON deltas to the terminal):**

```bash
agent --workspace /Users/kip/Code/grace-notes --print --trust \
  --output-format stream-json --stream-partial-output \
  "…same task-scoped prompt as above…"
```

**Isolated git worktree per subagent (optional, avoids file contention):**

```bash
agent --workspace /Users/kip/Code/grace-notes --print --trust \
  --worktree agent-235-task2 --worktree-base feat/sticky-completion-badge-expand-collapse-235 \
  "Complete ONLY Task 2 from docs/superpowers/plans/2026-04-08-sticky-completion-badge-235.md …"
```

**Parallel tasks (after Task 1 lands to avoid merge conflicts):** run two shells, each with a different `Task N`, then `wait`; resolve conflicts only if both touched the same file.

**Done when:** `agent` exits 0 and the subagent’s summary lists SwiftLint clean + commit hash; parent reviews the diff before merge.

---

## File structure

| File | Role |
|------|------|
| `GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift` | `@State` for sticky chip expansion; auto-collapse `Task`; scroll/timer reset; `onChange` when sticky hidden; tap vs long-press routing into chip; pass `showsCompletionTitle` into `JournalCompletionBarChip`. |
| `GraceNotes/GraceNotes/Features/Journal/Views/JournalCompletionBarChip.swift` | Collapsed layout (icon only + tighter padding), expanded layout (current icon + title); optional width animation; accessibility label/hint/custom action hooks. |
| `GraceNotes/GraceNotes/Resources/Localizable.xcstrings` | New accessibility strings (e.g. expanded/collapsed hints, custom action title for “show status meaning”). |
| `docs/superpowers/plans/2026-04-08-sticky-completion-badge-235.md` | This plan. |

---

## Product decisions locked in this plan (issue open questions)

| Topic | Decision |
|--------|-----------|
| Auto-collapse delay | Fixed **3.0s** after expansion; not user-configurable in Settings. |
| Expanded tap vs completion info | **Single tap** when expanded **collapses** only (per issue). **Long-press** and **VoiceOver custom action** invoke `completionBadgeTapped` so the meaning card remains reachable while the inline pill is hidden. |
| Scroll while expanded | **Reset** the 3s timer when `journalScrollOffsetY` moves more than `JournalScreenLayout.unlockToastScrollDismissThreshold` (20 pt) from a stored baseline while expanded; do not auto-collapse solely because of scroll. |
| Reduce Motion | Skip cosmetic width animation; still perform expand/collapse state changes immediately; preserve existing info-card animations from `JournalCompletionInfoPresentation`. |
| Sticky bar hides mid-expand | Set `stickyCompletionChipLabelExpanded = false` and cancel the collapse task when `stickyCompletionRevealedByScroll` becomes `false`. |

---

### Task 1: JournalScreen state, timer, scroll reset, sticky hide reset

**Files:**
- Modify: `GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift` (near existing `stickyCompletionRevealedByScroll` / `stickyJournalCompletionToolbarChip`)

- [ ] **Step 1: Add private layout constants**

In `private enum JournalScreenLayout`, add:

```swift
static let stickyCompletionChipAutoCollapseSeconds: TimeInterval = 3
```

- [ ] **Step 2: Add @State and baseline for scroll**

Near `@State private var stickyCompletionRevealedByScroll`:

```swift
@State private var stickyCompletionChipLabelExpanded = false
@State private var stickyCompletionChipCollapseTask: Task<Void, Never>?
@State private var stickyCompletionChipScrollBaselineForTimer: CGFloat?
```

- [ ] **Step 3: Add helpers (private extension on `JournalScreen`)**

```swift
private func cancelStickyCompletionChipCollapseTask() {
    stickyCompletionChipCollapseTask?.cancel()
    stickyCompletionChipCollapseTask = nil
}

private func scheduleStickyCompletionChipAutoCollapse() {
    cancelStickyCompletionChipCollapseTask()
    let seconds = JournalScreenLayout.stickyCompletionChipAutoCollapseSeconds
    stickyCompletionChipCollapseTask = Task { @MainActor in
        try? await Task.sleep(for: .seconds(seconds))
        guard !Task.isCancelled else { return }
        stickyCompletionChipLabelExpanded = false
        stickyCompletionChipCollapseTask = nil
    }
}

private func expandStickyCompletionChipLabel() {
    stickyCompletionChipLabelExpanded = true
    stickyCompletionChipScrollBaselineForTimer = journalScrollOffsetY
    scheduleStickyCompletionChipAutoCollapse()
}

private func collapseStickyCompletionChipLabel() {
    cancelStickyCompletionChipCollapseTask()
    stickyCompletionChipLabelExpanded = false
    stickyCompletionChipScrollBaselineForTimer = nil
}
```

- [ ] **Step 4: Reset expansion when sticky bar hides**

Inside `applyStickyCompletionRevealed`, when `revealed` becomes `false`, call `collapseStickyCompletionChipLabel()` (or inline the same: cancel task, set expanded false, clear baseline).

- [ ] **Step 5: Restart timer on scroll while expanded**

In `.onPreferenceChange(JournalScrollOffsetPreferenceKey.self)` where `journalScrollOffsetY` is set, after updating `journalScrollOffsetY`, add:

```swift
if stickyCompletionChipLabelExpanded, let baseline = stickyCompletionChipScrollBaselineForTimer {
    if abs(offsetY - baseline) > JournalScreenLayout.unlockToastScrollDismissThreshold {
        stickyCompletionChipScrollBaselineForTimer = offsetY
        scheduleStickyCompletionChipAutoCollapse()
    }
}
```

- [ ] **Step 6: Commit**

```bash
git add GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift
git commit -m "feat(journal): scaffold sticky completion chip expand/collapse state (#235)"
```

---

### Task 2: JournalCompletionBarChip collapsed and expanded layouts

**Files:**
- Modify: `GraceNotes/GraceNotes/Features/Journal/Views/JournalCompletionBarChip.swift`

- [ ] **Step 1: Add parameter**

Add after `let peopleCount: Int`:

```swift
/// When `false`, show only the tier symbol (toolbar stays compact).
let showsCompletionTitle: Bool
```

- [ ] **Step 2: Replace `labelCore` and horizontal padding**

Use a title branch only when `showsCompletionTitle`:

```swift
private var labelCore: some View {
    HStack(alignment: .center, spacing: AppTheme.spacingTight) {
        Image(ReviewRhythmFormatting.assetName(for: completionLevel))
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: tierIconLength, height: tierIconLength)
            .accessibilityHidden(true)
        if showsCompletionTitle {
            Text(completionTitle)
                .font(AppTheme.warmPaperToolbarChipTitle)
                .lineLimit(1)
                .minimumScaleFactor(toolbarCompletionTitleMinimumScaleFactor)
        }
    }
    .foregroundStyle(labelColor)
    .frame(maxHeight: .infinity)
}
```

In `body`, replace fixed `.padding(.horizontal, 14)` with:

```swift
.padding(.horizontal, showsCompletionTitle ? 14 : 10)
```

- [ ] **Step 3: Animate width (respect Reduce Motion)**

Wrap the inner label padding in `.animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: showsCompletionTitle)` only if `reduceMotion` is available from `@Environment(\.accessibilityReduceMotion)` (add property if missing).

- [ ] **Step 4: Commit**

```bash
git add GraceNotes/GraceNotes/Features/Journal/Views/JournalCompletionBarChip.swift
git commit -m "feat(journal): icon-only vs full sticky completion chip layout (#235)"
```

---

### Task 3: Wire gestures, accessibility, and call sites

**Files:**
- Modify: `GraceNotes/GraceNotes/Features/Journal/Views/JournalCompletionBarChip.swift`
- Modify: `GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift`
- Modify: `GraceNotes/GraceNotes/Resources/Localizable.xcstrings`

- [ ] **Step 1: Extend `JournalCompletionBarChip` callbacks**

Replace single `let onTap: () -> Void` with:

```swift
let onCollapseExpandTap: () -> Void
let onShowCompletionInfo: () -> Void
```

Apply:

- `Button(action: onCollapseExpandTap)` remains the main control.
- Add `.onLongPressGesture(minimumDuration: 0.45, pressing: nil) { onShowCompletionInfo() }` (tune duration to match HIG; stay consistent with other long presses in app if any).

- [ ] **Step 2: Accessibility**

Keep `accessibilityLabel` as the full sentence (status + counts) in **both** collapsed and expanded states. Set:

- `accessibilityHint` to `String(localized: "accessibility.stickyCompletionChipHint")` describing tap = expand/collapse and long-press = details (exact copy in Task 4). Re-test VoiceOver after implementation; adjust only if the default `Button` traits read poorly.

Add custom action:

```swift
.accessibilityAction(named: String(localized: "accessibility.stickyCompletionChipShowDetailsAction")) {
    onShowCompletionInfo()
}
```

- [ ] **Step 3: Update `stickyJournalCompletionToolbarChip` in `JournalScreen.swift`**

```swift
private var stickyJournalCompletionToolbarChip: some View {
    JournalCompletionBarChip(
        toolbarControlHeight: journalToolbarControlHeight,
        completionLevel: viewModel.completionLevel,
        gratitudesCount: viewModel.gratitudes.count,
        needsCount: viewModel.needs.count,
        peopleCount: viewModel.people.count,
        showsCompletionTitle: stickyCompletionChipLabelExpanded,
        onCollapseExpandTap: {
            if stickyCompletionChipLabelExpanded {
                collapseStickyCompletionChipLabel()
            } else {
                expandStickyCompletionChipLabel()
            }
        },
        onShowCompletionInfo: {
            let badge = CompletionBadgeInfo.matching(viewModel.completionLevel)
            completionInfoPresentation.completionBadgeTapped(badge, reduceMotion: reduceMotion)
            if completionInfoPresentation.isInfoCardPresented {
                completionHeaderScrollPulse &+= 1
            }
        }
    )
}
```

- [ ] **Step 4: Grep for other `JournalCompletionBarChip(` call sites**

If any (previews/tests), pass `showsCompletionTitle: true` and wire both closures to `{}` or meaningful preview actions.

- [ ] **Step 5: Run SwiftLint**

```bash
cd /Users/kip/Code/grace-notes && swiftlint lint
```

Expected: no new violations in touched files.

- [ ] **Step 6: Commit**

```bash
git add GraceNotes/GraceNotes/Features/Journal/Views/JournalCompletionBarChip.swift \
        GraceNotes/GraceNotes/Features/Journal/Views/JournalScreen.swift \
        GraceNotes/GraceNotes/Resources/Localizable.xcstrings
git commit -m "feat(journal): sticky completion chip tap/long-press and a11y (#235)"
```

---

### Task 4: Localization strings

**Files:**
- Modify: `GraceNotes/GraceNotes/Resources/Localizable.xcstrings`

- [ ] **Step 1: Add keys**

Add **American English** source strings (Translator fills `zh-Hans` later per workflow):

| Key | EN value (example — tune in app copy review) |
|-----|-----------------------------------------------|
| `accessibility.stickyCompletionChipHint` | `Tap to show or hide the status label. Touch and hold for what this status means.` |
| `accessibility.stickyCompletionChipShowDetailsAction` | `Explain status` |

Use Xcode String Catalog or hand-edit JSON to match existing `Localizable.xcstrings` shape.

- [ ] **Step 2: Audit**

```bash
cd /Users/kip/Code/grace-notes && grace l10n audit
```

(or `uv run --project Scripts/gracenotes-dev grace l10n audit` if `grace` not on PATH)

Expected: new keys referenced from Swift are present.

- [ ] **Step 3: Commit**

```bash
git add GraceNotes/GraceNotes/Resources/Localizable.xcstrings
git commit -m "l10n: sticky completion chip accessibility copy (#235)"
```

---

### Task 5: Verification (macOS / Simulator)

**Files:**
- None (manual); update PR / issue acceptance checklist with outcomes.

- [ ] **Step 1: SwiftLint**

```bash
swiftlint lint
```

Expected: PASS (exit 0 or only acceptable repo baseline).

- [ ] **Step 2: Build + unit tests** (macOS with Xcode 26+)

```bash
grace ci
```

Expected: lint + simulator build succeed; fix any regressions from `JournalCompletionBarChip` initializer changes in tests.

- [ ] **Step 3: Manual matrix on iPhone 17 Pro simulator**

Document results in PR:

1. Scroll down until sticky chip appears: **icon only**.
2. Tap: **expands** with label; after **3s** idle, **collapses**.
3. Tap expanded: **collapses** immediately; timer canceled.
4. Long-press (collapsed or expanded): **completion info card** appears; verify scroll pulse still works.
5. Scroll while expanded: timer **restarts** (collapse happens ~3s after scroll stops).
6. Scroll back to top (sticky hides): chip **collapsed** next time it appears.
7. **Dynamic Type** max in standard range: chip readable; **Dark Mode** tier colors OK.
8. **VoiceOver**: rotor/custom action opens details; hint matches behavior.

- [ ] **Step 4: Commit** (if only documentation / checklist in PR body — no file commit required)

---

## Self-review

**1. Spec coverage:** Default collapsed icon — Task 2. Expand on tap — Task 3. Auto-collapse 3s — Task 1. Explicit collapse on expanded tap — Task 3. Accessibility — Tasks 3–4. Light/dark/dynamic type — Task 5. Out of scope (completion logic, moving badge) — not touched.

**2. Placeholder scan:** No TBD steps; open issues from GitHub are resolved in the table above.

**3. Type consistency:** `JournalCompletionBarChip` gains `showsCompletionTitle` and two callbacks; all call sites updated in Task 3 Step 4.

---

**Plan complete and saved to `docs/superpowers/plans/2026-04-08-sticky-completion-badge-235.md`.**

**Execution options:**

1. **Subagent-Driven (recommended)** — Dispatch a fresh subagent per task (use Cursor **`agent`** CLI as above), review between tasks, fast iteration. **REQUIRED SUB-SKILL:** superpowers:subagent-driven-development.

2. **Inline Execution** — Run tasks in one session using superpowers:executing-plans with checkpoints.

**Which approach?**

## Grace Notes UAT Notes — Release 0.3.4

Date: 2026-03-19

## Grace Note Screen

### Completion badge semantics and education

Current behavior:

- Completion status labels now use `In Progress`, `Seed`, and `Harvest`.
- Tapping a completion badge opens an inline meaning card with concise status guidance.
- The meaning card remains visible until dismissed (tap outside card), instead of auto-dismissing.

Validation intent:

- Ensure each completion state is reachable and displays the correct label and icon.
- Verify meaning card messaging matches completion thresholds:
  - `Seed`: at least 1 gratitude, 1 need, and 1 person
  - `Harvest`: full reflection completion
- Confirm behavior respects accessibility reduce-motion / reduce-transparency settings.

### Section progress and status continuity

Validation intent:

- Confirm section progress dots remain aligned with section editing/filled states.
- Ensure chip add/edit flow still preserves input momentum with updated completion gating.

## Review Screen

### Timeline badge consistency

Current behavior:

- Timeline rows now display status chips aligned with Today naming (`In Progress`, `Seed`, `Harvest`).

Validation intent:

- Verify timeline chip text and icon treatment remain consistent with Grace Note screen semantics.
- Validate long-label behavior at larger Dynamic Type sizes.

## Settings Screen

### iCloud sync control and privacy messaging

Current behavior:

- Settings Data section includes an `iCloud sync` toggle.
- Privacy helper text describes iCloud-on vs iCloud-off outcomes and clarifies apply timing.

Validation intent:

- Toggle persistence should survive relaunch and reflect expected state on reopen.
- Copy should remain clear in localization and at accessibility text sizes.
- Export flow should continue working regardless of iCloud sync toggle value.

## Regression targets

- Deterministic summarization label truncation expectations (including mixed-script input).
- Reminder permission denied flow and `Open Settings` behavior.
- UI test accessibility identifier targeting for add-chip actions.

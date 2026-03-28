---
name: explain
description: Explain code, bugs, and fixes in plain language for programming-literate readers—lead with user-visible impact and product behavior, not Swift trivia or diffs.
user-invokable: true
args:
  - name: target
    description: The code area, feature, PR, or bug narrative to explain (optional)
    required: false
  - name: depth
    description: summary (default) or with technical appendix when the user wants implementation detail
    required: false
---

Turn convoluted logic, bug stories, and change lists into **short explanations** a busy reader can scan in seconds—grounded in **what the app does** and **what people experience**, not in repository structure.

## Purpose

- Make **meaning and impact** obvious first: what was wrong or confusing, what changes for the user, why it matters.
- Bridge **implementation** and **outcome** without assuming Swift/SwiftUI/SwiftData fluency; translate stack ideas only when they serve the story.
- Standardize a **CEO / general-user voice** by default: calm, concrete, and non-jargony. Reserve “tech lead” depth for when the user asks or when omitting it would mislead.

## Non-purpose

- **Not** UX copy editing—use `clarify`.
- **Not** design simplification—use `distill`.
- **Not** architecture sign-off or QA gates—use `architect` / `qa-review` when those are the job.
- **Not** a tutorial on programming basics—the audience already programs; skip lectures on loops, types, or “what is MVC.”

## Audience

Assume readers are **fluent programmers** who may not know **Swift ecosystem details**. They want the **story of the product**: behavior, regressions, guarantees, and surprises—not a guided tour of files unless they ask.

## Default output format

Use this order unless the user specifies otherwise:

1. **Headline** — One line: what this is about in product terms.
2. **User impact** — Bullets or a tight paragraph: what people see, lose, risk, or gain.
3. **Behavioral narrative** — Prefer “when the app …” / “expected … / actually … / after the fix …” over API or type names.
4. **Technical appendix** — Only if `depth` calls for it or the user asked. Even then, open with user impact, then add file names, types, or mechanisms as supporting detail.

Defer **file paths, symbol names, and diff-shaped detail** unless requested. If you include them, label them clearly as “implementation detail” so skimmers can skip.

## Bugfix rubric (no diff-first)

For fixes and incidents, structure the narrative like this—**without** centering hunks or line-level change lists:

| Block | What to say |
|-------|-------------|
| **Symptom** | What the user sees or loses (screens, timing, data wrong/missing, crash). |
| **Cause (plain)** | What the app was doing wrong *in behavior terms* (e.g. “saved too early,” “showed stale data,” “skipped a step when X was empty”). Swift/SwiftData may appear briefly if it clarifies the bug. |
| **Fix effect** | What users get now—reliability, correctness, fewer surprises. One sentence tying behavior to trust is enough when obvious. |

**Example shape** (illustrative, not a template to paste verbatim):

- *Symptom:* Saving sometimes dropped the last gratitude the user typed.
- *Cause:* The screen treated “tap Save” as final before the field finished committing its text to the entry the app was about to store.
- *Fix effect:* Save waits until the in-progress text is part of the entry, so what users see on screen matches what gets stored.

Do not lead with “changed `Foo` in `Bar.swift`” unless the user asked for that level of detail.

## Stop conditions

If **symptoms, repro, or intended behavior** are unclear, ask **one focused question** instead of inventing user impact. Do not fabricate stakeholder-friendly fluff.

## Decision checklist

- [ ] Would a non-Swift programmer still get the gist without opening the codebase?
- [ ] Does the opener answer “so what?” for someone using the app?
- [ ] Are technical names optional add-ons, not the main thread?
- [ ] For fixes, are symptom → plain cause → user-visible effect all addressed?

## Handoff contract

If this spans sessions, end with: what you explained, what remains ambiguous, and what detail was deliberately left out (e.g. “no appendix—user asked for summary only”). Prefer linking a **PR or issue** for anything load-bearing.

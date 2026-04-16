---
name: memory
description: Proactively distill durable lessons into MEMORY.md after frictional human–agent loops (reverts, repeated instructions, explicit tradeoffs).
---

# Agent memory updates

## Purpose

Capture **short, durable** signals in repo-root [`MEMORY.md`](../../../MEMORY.md) so **future agents** do not repeat rejected approaches, miss stated priorities, or ignore recurring human constraints.

## Non-purpose

- Chat logs, long rationales, or full PR bodies (link the PR in one line if needed).
- Duplicating what is already a clear line in `MEMORY.md`.
- Updating memory for trivial one-shot tasks with no correction loop.

## When to run (automatic = same session, before you stop)

Run this checklist **before wrapping** work if **any** trigger below was true in the conversation. **Do not wait** for the human to say “update MEMORY.”

### Triggers (any one → evaluate for an entry)

- **Reverts:** The human **reverted** a change, or you iterated **≥ 2** failed approaches on the **same** UX/behavior axis.
- **Friction signals:** Tone or wording shows **frustration**, **urgency**, or **repetition** (e.g. “again,” “stop,” “still wrong,” “I already said,” emphasis restating the same rule).
- **Repeated constraints:** The human states the **same** requirement, limit, or priority **more than once** (especially after you missed it once).
- **Explicit tradeoff / priority:** The human names a **winner** when values conflict (e.g. feel vs layout metrics; ship scope vs polish).
- **Corrections to agent defaults:** “Don’t do X here,” “never bundle Y,” “always verify Z on device”—if it should apply **beyond this one task**.

### Anti-triggers (skip)

- Single misunderstanding fixed in one patch with no reverted or contested direction.
- Information that lives **only** in an issue/PR and is not a **general** preference for the codebase.

## Workflow

1. **Read** [`MEMORY.md`](../../../MEMORY.md) (entries section): is the lesson **already** there? If yes, **stop** (or add **one clause** to an existing line only if it adds a *new* non-duplicate fact).
2. **Draft one line** (≤ ~200 chars): date prefix `YYYY-MM-DD |` when it’s decision-dated; **scope** prefix (`UI:`, `workflow:`, `human pref:`) helps scanning.
3. **Append** under `## Entries` in [`MEMORY.md`](../../../MEMORY.md). Keep **one claim per line**.
4. **Commit** when you touch `MEMORY.md` (alone or with other changes): `docs(memory): …` with a short subject.

## Output

- Updated `MEMORY.md` (or explicit note in reply: “no new line; already captured / not durable”).
- No wall of text to the human—**actions speak**.

## Stop conditions

- If the “lesson” is unclear, **ask one** focused question instead of inventing a line.
- If the only durable artifact is a **GitHub decision**, prefer **one line + PR/issue link** over copying the thread.

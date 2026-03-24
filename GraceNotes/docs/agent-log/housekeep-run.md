# Housekeep run — end-to-end orchestration

This playbook defines how to drive an initiative from **requirements / `gh issue`** to **implementation, tests, QA notes, and UAT-ready handoff**, using `GraceNotes/docs/agent-log/initiatives/<id>/` as shared state.

It supports:

- **Single conversation** — one Agent session runs phases in order (switching “hats” per phase).
- **Multi-conversation relay** — each phase ends with a **copy-paste prompt** for the next session (next role + skill).

Cursor does **not** natively spawn sub-agents or auto-open chats; **housekeep run** means **documented phases + handoff prompts**, optionally executed by one model thread.

## Before you start

1. Create the initiative (short command is enough): see [.agents/skills/housekeep/SKILL.md](../../../.agents/skills/housekeep/SKILL.md) — e.g. “Start on gh issue #50”.
2. Note the folder path: `GraceNotes/docs/agent-log/initiatives/<initiative-id>/`.
3. Confirm **where tests run**: iOS builds/tests need **macOS + Xcode** (see repo `AGENTS.md`). Linux-only agents can still edit Swift and docs but cannot run `xcodebuild`.

## Standard phase order (adjust if trivial)

| Phase | Role / skill | Primary outputs | Reads |
|-------|----------------|-----------------|--------|
| 1 | **Strategist** | `brief.md` | Issue / product doc, `CHANGELOG` if relevant |
| 2 | **Architect** | `architecture.md` | `brief.md` |
| 3 | **Strategist review** (optional loop) | Comment in `pushback.md` or `brief.md` | `architecture.md` vs `brief.md` |
| 4 | **Architect revise** (if pushback) | Update `architecture.md` | `pushback.md` — **cap loops** (e.g. max **2** rounds) |
| 5 | **Designer** (if UI-heavy) | `design.md` | `brief.md`, `architecture.md` |
| 6 | **Builder** | Code + tests | `architecture.md`, optional `design.md` |
| 7 | **Test Lead** | `testing.md` | Builder diff, `architecture.md` close criteria |
| 8 | **QA Reviewer** | `qa.md` | Same + user-facing copy |
| 9 | **Release Manager** | `release.md`, branch/PR hygiene | `qa.md`, `testing.md`, `architecture.md` |

**Stop early** if a phase’s skill says escalate (e.g. scope conflict → Strategist).

## Review loop (Strategist ↔ Architect)

- Strategist may **approve** (state in `brief.md` or `pushback.md`: no blocking `Open Questions`) or **push back** using [SCHEMA.md](./SCHEMA.md) pushback fields in `pushback.md`.
- Architect addresses pushback in `architecture.md` and sets **`Next Owner`** to Strategist or Builder.
- Enforce a **maximum number of review rounds** (recommended: **2**) to avoid endless revision.

## Single-conversation instruction

Paste or adapt:

```text
You are running a Housekeep run for initiative GraceNotes/docs/agent-log/initiatives/<initiative-id>/.

Execute phases in order. For each phase, adopt ONLY that role’s skill from `.agents/skills/<skill-slug>/SKILL.md` (e.g. `strategize`, `architect`, `designer`, `build`, `test`, `qa-review`, `vc`) and edit ONLY the files that role owns (see roles-index). After each phase, write handoff fields: Decision, Open Questions, Next Owner.

Phases: (1) Strategist (`strategize`) → brief.md (2) Architect → architecture.md (3) Optional: Strategist reviews architecture; if misaligned, append pushback.md and Architect revises — max 2 rounds (4) Designer only if UI-heavy → design.md (5) Builder (`build`) → code + tests (6) Test Lead (`test`) → testing.md (7) QA Reviewer (`qa-review`) → qa.md (8) Release Manager (`vc`) → release.md

If the user chose multi-session mode, STOP after each phase and output the “Next session prompt” block instead of continuing.

On macOS, run tests with the project’s documented xcodebuild command when Builder/Test Lead requires it. Summarize UAT steps for the human at the end.
```

## Multi-conversation relay — “next session prompt” format

Whenever a phase **completes** in relay mode, the agent **must** end with a single fenced block the user can copy into a **new** chat:

````markdown
### Next session — handoff prompt (copy below)

**Role:** <NextRole>  
**Skill file:** `.agents/skills/<slug>/SKILL.md` (attach or @ this skill in Cursor)

**Initiative:** `GraceNotes/docs/agent-log/initiatives/<initiative-id>/`

**Read first:** <list 2–5 files>

**Your job:** <one sentence>

**Constraints:** <e.g. do not expand scope beyond brief.md Scope In>

**Done when:** <observable outcome, e.g. architecture.md has testable close criteria>

---
<paste everything from “Role:” through “Done when:” into the next chat>
````

Example **Next Owner** after Strategist finishes `brief.md`:

- **Role:** Architect  
- **Read first:** `brief.md`, `SCHEMA.md`  
- **Your job:** Produce `architecture.md` with goals, non-goals, risks, close criteria, sequencing.  
- **Done when:** `Next Owner` is set (Designer or Builder).

## Thin commands (for the user)

- “**Housekeep run, single chat, initiative `<path>`**” — run all phases in one conversation until blocked or done.
- “**Housekeep run, relay, initiative `<path>`**” — run **one** phase, then emit the handoff prompt only.
- “**Housekeep run from gh issue #N**” — initiative start via **housekeep** skill (if needed), then Strategist phase or full pipeline per mode.

*Informal alias:* “**Master run, …**” means the same as **Housekeep run** (this file used to be `MASTER-RUN.md`).

## Multi-agent auto-scheduling — implementation options

These are **outside** this markdown file’s scope but are the usual approaches if you want more automation later:

1. **Single model, explicit playbook (this doc)** — Lowest friction; one or many chats; no extra infra.
2. **Cursor Rules / project instructions** — Pin the Housekeep run block so every session knows the phase order and handoff format.
3. **Shell + git hooks / Makefile targets** — Automate **mechanical** steps only: `validate-agent-log`, branch creation, running `xcodebuild` on a Mac (CI or local), failing the pipeline if tests fail. Does not replace Strategist judgment.
4. **CI (GitHub Actions) on macOS runners** — On PR: lint, test, optional SwiftLint; post results as a comment. “QA” becomes **gatekeeping**, not creative review.
5. **External orchestrator** — A script or service (e.g. n8n, Temporal, custom worker) that calls **LLM APIs** with role-specific system prompts, passing file contents in/out of the repo. Heavy; you own prompts, secrets, and cost.
6. **IDE / vendor features** — If Cursor (or others) ship **workflow or multi-agent orchestration**, re-map phases to that UI; keep `agent-log` as the **source of truth** for handoffs.

**Reality check:** Fully unattended “Strategist ↔ Architect until perfect” plus production code without human **UAT** is risky. Use **relay mode + human checkpoint** after architecture or after Builder for best results.

## Related

- [index.md](./index.md) — active initiatives  
- [SCHEMA.md](./SCHEMA.md) — handoff and pushback fields  
- [.agents/skills/roles-index/SKILL.md](../../../.agents/skills/roles-index/SKILL.md) — shared contract  

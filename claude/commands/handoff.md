# Session Handoff

Generate or resume a session handoff document to preserve full session context for continuation in a new conversation.

## Arguments

`$ARGUMENTS` contains either:
- Empty or a slug → **generate mode**
- `continue <slug>` → **resume mode**

---

## Generate Mode

Analyze the ENTIRE current conversation and execute these steps:

### Step 1 — Identify slug

If no slug was provided in `$ARGUMENTS`, suggest one based on the main topics of the session using the format `<project>-<topic>` (e.g., `mssp-backend-api`, `catalog-spa-auth`).

Ask the user to confirm or provide a different one before proceeding.

### Step 2 — Memory sweep

Review the session for decisions, context, or references that are NOT yet saved as memory files. For each one found:

1. Check MEMORY.md to see if a related memory already exists
2. If it exists, update it with the new information
3. If it doesn't, create a new memory file with proper frontmatter (type: project, reference, or feedback)
4. Update MEMORY.md index

Present the list of memories created/updated to the user.

### Step 3 — Generate handoff

Create the handoff file at: `<memory_directory>/handoff_<YYYY-MM-DD>T<HH-MM>_<slug>.md`

Use this structure:

```
---
name: handoff-<YYYY-MM-DD>T<HH-MM>-<slug>
description: "Session handoff: <what was covered>"
metadata:
  type: project
---

# Handoff: <descriptive title>

**Date:** YYYY-MM-DD HH:MM

## Session Overview
What this session covered and the general context.

## Tasks

### <Task name or ticket ID>
**Status:** done | in progress | blocked | waiting for decision
**Depends on:** <other task, if applicable>

**Objective:** What and why.

**What Was Done:** What was produced, attempted, or discarded (and why). Include links to PRs, tickets, branches.

**Current State:** Where we stopped. What works, what is broken, what is uncommitted or unpushed.

**Next Steps:** Ordered, actionable list.

**Open Questions:** Things needing decision or investigation.

**Artifacts:** Files, branches, commands, outputs (ARNs, endpoints, IDs) the next session needs.

---
(repeat for each task)

## Instructions for Next Session
Pitfalls to avoid, things NOT to repeat, cross-cutting concerns between tasks.
```

Rules for generating content:
- One task block per distinct piece of work in the session
- Tasks with status "done" get reduced blocks: objective, what was done, and artifacts/outputs that other tasks need. No next steps or open questions.
- Never duplicate what git log or Jira already shows — use links for what is already recorded, write what is NOT recorded anywhere else
- Focus on the WHY behind decisions and the EXACT point where work stopped
- Capture uncommitted or unpushed work with enough detail to recreate it if needed
- All content in English

### Step 4 — Update MEMORY.md

Add an entry for the handoff:
`- [Handoff: <title>](handoff_<date>T<time>_<slug>.md) — <summary>`

### Step 5 — Summary

Show the user:
- Memories created/updated (count and names)
- Handoff file path
- Brief summary of what was captured

---

## Resume Mode

When `$ARGUMENTS` starts with `continue`:

### Step 1 — Find handoff

Extract the slug from `$ARGUMENTS`. Search the memory directory for files matching `handoff_*_<slug>.md`.

If multiple matches exist, list them with dates and times and ask which one to use.

### Step 2 — Load context

1. Read the handoff file
2. Read MEMORY.md to identify related project and reference memories
3. Read those related memories

### Step 3 — Present state

Summarize to the user:
- What the previous session covered
- Current state of each in-progress task
- Dependencies between tasks
- Recommended first action

Then ask: "What do you want to pick up first?"

### Step 4 — Clean up

Remove the consumed handoff entry from MEMORY.md. Keep the file in the memory directory for history.

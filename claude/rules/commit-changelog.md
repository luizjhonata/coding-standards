---
paths:
  - "CHANGELOG.md"
---

# Commit Finalization and CHANGELOG Updates

When asked to finalize commits, update the changelog, or squash WIP commits, follow this workflow.

## Step 1: Read and Analyze Commits

```bash
git log -N --format='%H%n%s%n%b%n---COMMIT_END---'
git log -N --stat
git diff HEAD~N..HEAD
git branch --show-current   # extract Jira ticket (e.g. feat/TICKET-1234 -> TICKET-1234)
```

## Step 2: Update CHANGELOG.md

Add entries under `## [Unreleased]`. Subsection order follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/): `### Added`, `### Changed`, `### Deprecated`, `### Removed`, `### Fixed`, `### Security`.

### Entry Rules

- Lowercase past tense verb (`added`, `changed`, `fixed`, `removed`)
- Append Jira link: `- [TICKET-XXXX](https://company.atlassian.net/browse/TICKET-XXXX)`
- Wrap identifiers in backticks
- One entry per logical change
- Always append new entries **below** existing entries within the same subsection — never insert above them, so that the most recent addition is the last item in the list

### Example

```markdown
### Added

- added 8 alert actions (`list_alerts`, `get_alert`, ...) to `CaseManagement` node - [TICKET-1234](https://company.atlassian.net/browse/TICKET-1234)

### Changed

- changed `CaseManagement` config field from `baseUrl` to `endpoint` - [TICKET-1234](https://company.atlassian.net/browse/TICKET-1234)

### Fixed

- fixed SMTP node to match TypeScript reference implementation - [TICKET-5678](https://company.atlassian.net/browse/TICKET-5678)
```

## Step 3: Squash WIP Commits

**NEVER squash without explicit user confirmation.** Show: number of commits, proposed message, wait for approval.

```bash
git add CHANGELOG.md
git reset --soft HEAD~N
git commit -m "<improved message>"
```

## Commit Message Format

```
type(TICKET-XXXX): concise imperative description

- imperative verb bullet points
- group related changes logically

Signed-off-by: Author Name <author@example.com>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.
Title: max 72 chars, imperative mood, lowercase after colon, no trailing period.

## Post-Squash

Remind user that `git push --force-with-lease` is required. NEVER force push without explicit request.

## CHANGELOG Rebase Conflict Resolution

When resolving CHANGELOG.md conflicts during rebase, NEVER manually merge sections. Follow this pattern:

1. `git checkout origin/main -- CHANGELOG.md` — restore the file entirely from main
2. Add ONLY your new entry to the appropriate section
3. `git add CHANGELOG.md && git rebase --continue`

**Why:** CHANGELOG conflicts are tricky because both sides add entries under `## [Unreleased]`. Manual merge resolution can accidentally incorporate main's entries into your commit's diff — which then shows as deletions when the branch is compared against main.

**Verify:** After resolution, run `git diff origin/main -- CHANGELOG.md` — the diff should show ONLY your added lines, zero deletions.

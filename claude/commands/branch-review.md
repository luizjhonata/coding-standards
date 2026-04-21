Review code changes in the current branch compared to main. The goal is to validate architecture, design, and standards compliance — things that automated tools (lint, test) cannot catch.

**Prerequisite**: `/branch-lint` and `/branch-test` must pass before running this command. If they haven't been run, remind the user and stop.

All review output MUST be in English.

## Step 1: Gather changes

1. Get the list of changed files: `git diff --name-only main...HEAD`
2. Get the full diff: `git diff main...HEAD`
3. Filter out deleted files.
4. If no changed files are found, report "No changes to review" and stop.

## Step 2: Detect project type

- If `go.mod` exists → **Go**
- If `package.json` exists → **Frontend** (JavaScript/TypeScript)
- If both exist, ask the user which one to review.
- If neither exists, review against universal standards only.

## Step 3: Review each changed file

For each changed file:

1. Read the diff to understand what was added or modified.
2. Read the full file only when the diff doesn't provide enough context (e.g., to check architecture layer, class structure, or function placement).
3. Check against **all rules loaded in context** (CLAUDE.md universal standards and the applicable language-specific rules). Do NOT rely on a hardcoded checklist — always reference the actual loaded rules.

Focus exclusively on what lint and test tools **cannot catch**:

- **Architecture compliance**: correct layer separation, domain not importing infrastructure, business logic placement, entity invariants, framework-agnostic entities
- **Design principles**: SRP violations, input mutation, duplicated logic across files, missing abstractions, unnecessary coupling
- **Naming semantics**: do names communicate intent, correct component naming patterns, repository method vocabulary
- **Code organization**: files in the right layer/directory, correct separation of concerns
- **Missing tests**: does every new production function have a corresponding test file
- **Domain design**: rich vs anemic models, value objects used where appropriate
- **Test quality**: ask "what bug would this test catch?" — flag smoke tests with near-zero value

Do NOT flag issues that lint or static analysis already covers (formatting, import order, unused variables, error wrapping syntax, etc.).

## Step 4: Classify findings

- **Critical** — must fix before merge: architecture violations, domain layer corruption, missing tests for new code, security issues, any `eslint-disable`
- **Suggestion** — should fix before merge: naming doesn't match conventions, code in wrong layer, anemic domain models, code quality patterns
- **Nice to have** — optional: opportunities to improve design without rule violations

## Step 5: Report results

```
## Review Summary

**Files reviewed**: X
**Findings**: X critical, X suggestion, X nice to have

### Critical (must fix before merge)
- `file.go:42` — [Architecture] description of the issue and which rule it violates

### Suggestions (should fix before merge)
- `file.go:15` — [Naming] description of the issue

### Nice to have
- `file.go:78` — suggestion for improvement

### Positive
- what was done well

### Clean Files
- `file.go` — no issues found
```

## Step 6: Fix issues (if requested)

Do NOT auto-fix anything. Present the report and wait for the user to decide:
- If the user asks to fix all, fix in order: critical → suggestion → nice to have.
- If the user asks to fix specific items, fix only those.
- After any code changes, remind the user: "Code was modified during review. Run `/branch-lint` and `/branch-test` to ensure changes pass before committing."

# Coding Standards

Actionable coding standards for AI-assisted development. Ensures consistent, high-quality code generation across projects regardless of the AI tool being used.

Currently covers **Go backend**, **React/TypeScript frontend**, and **Terraform/Terragrunt infrastructure**, with plans to expand to other stacks.

These rules are designed for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) but the standards themselves are tool-agnostic.

## What's included

### CLAUDE.md (universal standards)

Core rules loaded in every session regardless of language: architecture (Clean Architecture + DDD), design principles, commit conventions, development workflow (TDD), pre-PR validation, agent usage, and self-review checklist.

### Rules (path-scoped)

Loaded automatically when editing matching files:

| Rule | Scope |
|------|-------|
| **Go backend** | |
| `golang.md` | All `.go` files — architecture, code style, type system, logging, linting, SonarQube, security |
| `go/api-design.md` | Controllers, requests, responses, mappers |
| `go/controllers.md` | Gin controller patterns and Swagger |
| `go/database.md` | Repositories, migrations, transactions |
| `go/dependency-injection.md` | Wire and manual DI |
| `go/repository-testing.md` | Repository test patterns |
| `go/testing.md` | Build flags, BDD, parallel tests, sub-test naming, builders, testify |
| **Frontend** | |
| `frontend/react-general.md` | React, TypeScript, styled-components, ESM/CJS |
| `frontend/type-safety.md` | Runtime type safety for TS/JS — validate external data, narrowing, guards |
| `frontend/osd-plugin.md` | OpenSearch Dashboards plugin development |
| **Infrastructure** | |
| `infra/terraform.md` | Terraform, Terragrunt, Helm, version verification |
| `terra-cli.md` | Terraform/Terragrunt CLI wrapper usage |
| **General** | |
| `commit-changelog.md` | CHANGELOG.md — chlog and legacy workflows, entries, rebase conflict resolution |
| `project-onboarding.md` | README, main.go, go.mod, Dockerfile |
| `azure-devops-pr.md` | Azure DevOps PR descriptions via MCP |

### Commands

| Command | Description |
|---------|-------------|
| `/blint` | Run linter on changed files only (Go and Frontend), auto-fix and retry |
| `/btest` | Run tests for changed files only (Go and Frontend), fix failures and retry |
| `/breview` | Review architecture, design, and standards compliance on changed files |
| `/jira-create` | Create Jira tickets (Epic, Story, Bug, Subtask) with structured content |
| `/handoff` | Generate or resume a session handoff document to continue work in a new conversation |

### Recommended workflow

All commands compare committed changes in the current branch against `main`. Commit your work before running them.

```
write code → commit → /blint → /btest → commit fixes → /breview → fix if needed → /blint → /btest → commit → push
```

1. **`/blint`** first — auto-fixes formatting and catches static analysis issues
2. **`/btest`** second — runs tests and fixes failures
3. **Commit** any fixes from lint and test
4. **`/breview`** last — read-only analysis of architecture, design, and naming (only checks what automated tools can't catch)
5. If review leads to code changes, **re-run `/blint` and `/btest`** to ensure nothing broke
6. **Commit and push**

### Shell commands

Standalone shell helpers, installed separately from the Claude rules:

| Command | Description |
|---------|-------------|
| `cs` | Claude session finder — lists recent Claude Code sessions with their directory, start/last activity times, and first/last prompts, then `cd`s into the chosen one and resumes it. Handy for picking up work after a reboot. |

Usage:

```
cs                 # list recent sessions and pick one to resume
cs <keyword>       # show only sessions whose directory or prompts contain <keyword>
                   #   e.g. `cs payments` matches ~/work/payments-api or a prompt about payments
cs --list          # print the table only, no selection prompt
cs --limit 40      # show more sessions (default is 20)
```

Running `cs` prints a numbered table — for each session you see its directory, how long ago it was last active, and both the first prompt (what it was about) and the last prompt (where you left off). You then type a number to resume that session:

```
 1  ~/work/payments-api  (2h)
     ↪ start  Fri 20/06 09:14:  implement webhook retry with exponential backoff
     ↩ last   Fri 20/06 16:52:  add a test for the max-retries ceiling
 2  ~/work/payments-api  (5h)
     ↪ start  Fri 20/06 11:03:  why is the idempotency key being ignored on refunds
     ↩ last   Fri 20/06 13:40:  fixed — it was lowercased before the lookup
 3  ~/work/auth-service  (1d)
     ↪ start  Thu 19/06 15:20:  add rate limiting to the login endpoint
     ↩ last   Thu 19/06 15:58:  done, 5 attempts per minute per IP

Number to resume (Enter to cancel): 1
```

In this example, two sessions share the same directory (`payments-api`); the `start`/`last` lines and timestamps let you tell which one continues the work you care about — usually the most recent.

## Installation

### Global (applies to all projects)

```bash
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-rules.sh | sh
```

### Project-level

```bash
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-rules.sh | sh -s ./my-project
```

### Global force overwrite (no prompts)

```bash
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-rules.sh | sh -s -- --force
```

### Project-level force overwrite (no prompts)

```bash
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-rules.sh | sh -s -- --force ./my-project
```

### `cs` Claude session finder (separate installer)

Installs `~/.local/bin/claude-sessions.py` and adds a `cs` function to your shell rc file. Requires `python3` (3.7+) and the `claude` CLI in PATH.

> An **rc file** ("run commands") is the startup script your shell runs every time it opens — it holds your aliases, functions, and environment variables. For most people that's `~/.zshrc` (zsh) or `~/.bashrc` (bash); the installer detects which one you use.

```bash
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-cs.sh | sh
```

By default the installer auto-detects your shell and adds the function to `~/.zshrc` (zsh) or `~/.bashrc` (bash). To overwrite the script without prompting, or to target a non-default rc file:

```bash
# overwrite an existing install without prompting
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-cs.sh | sh -s -- --force

# install into a specific rc file (overrides auto-detection)
curl -fsSL https://raw.githubusercontent.com/luizjhonata/coding-standards/main/install-cs.sh | sh -s -- /path/to/your/rc-file
```

## Structure

```
coding-standards/
├── install-rules.sh
├── install-cs.sh
├── cli/
│   └── cs/
│       ├── claude-sessions.py
│       └── cs.sh
└── claude/
    ├── CLAUDE.md
    ├── commands/
    │   ├── blint.md
    │   ├── btest.md
    │   ├── breview.md
    │   ├── handoff.md
    │   └── jira-create.md
    └── rules/
        ├── golang.md
        ├── go/
        │   ├── api-design.md
        │   ├── controllers.md
        │   ├── database.md
        │   ├── dependency-injection.md
        │   ├── repository-testing.md
        │   └── testing.md
        ├── frontend/
        │   ├── react-general.md
        │   ├── type-safety.md
        │   └── osd-plugin.md
        ├── infra/
        │   └── terraform.md
        ├── azure-devops-pr.md
        ├── commit-changelog.md
        ├── project-onboarding.md
        └── terra-cli.md
```

## Roadmap

- [ ] Java backend standards
- [ ] TypeScript backend standards

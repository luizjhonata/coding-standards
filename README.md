# Coding Standards

Actionable coding standards for AI-assisted development. Ensures consistent, high-quality code generation across projects regardless of the AI tool being used.

Currently covers **Go backend** and **Terraform/Terragrunt infrastructure**, with plans to expand to other stacks.

These rules are designed for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) but the standards themselves are tool-agnostic.

## What's included

### CLAUDE.md (global standards)

Core rules loaded in every session: architecture (Clean Architecture + DDD), design principles, code style, type system, error handling, linting, security, testing workflow, and commit conventions.

### Rules (path-scoped)

Detailed patterns loaded automatically when editing matching files:

| Rule | Scope |
|------|-------|
| **Go backend** | |
| `api-design.md` | Controllers, requests, responses, mappers |
| `controllers.md` | Controller files |
| `database.md` | Repositories, migrations |
| `dependency-injection.md` | DI container and wire files |
| `repository-testing.md` | Repository test files |
| `testing.md` | Test files, builders, doubles |
| **Infrastructure** | |
| `terra-cli.md` | Terraform/Terragrunt files |
| **General** | |
| `commit-changelog.md` | CHANGELOG.md |
| `project-onboarding.md` | README, main.go, go.mod, Dockerfile |

### Commands

| Command | Description |
|---------|-------------|
| `/lint` | Run linter on changed files only (Go and Frontend), auto-fix and retry |
| `/test` | Run tests for changed files only (Go and Frontend), fix failures and retry |

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

## Structure

```
coding-standards/
├── install-rules.sh
└── claude/
    ├── CLAUDE.md
    ├── commands/
    │   ├── lint.md
    │   └── test.md
    └── rules/
        ├── api-design.md
        ├── commit-changelog.md
        ├── controllers.md
        ├── database.md
        ├── dependency-injection.md
        ├── project-onboarding.md
        ├── repository-testing.md
        ├── terra-cli.md
        └── testing.md
```

## Roadmap

- [ ] Java backend standards
- [ ] TypeScript backend standards
- [ ] TypeScript frontend standards
- [ ] React standards

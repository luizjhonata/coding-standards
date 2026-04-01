# Coding Standards

Actionable coding standards for AI-assisted development. Ensures consistent, high-quality code generation across projects regardless of the AI tool being used.

Currently covers **Go backend** and **Terraform/Terragrunt infrastructure**, with plans to expand to other stacks.

These rules are designed for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) but the standards themselves are tool-agnostic.

## What's included

### CLAUDE.md (universal standards)

Core rules loaded in every session regardless of language: architecture (Clean Architecture + DDD), design principles, commit conventions, development workflow (TDD), agent usage, and self-review checklist.

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
| `go/testing.md` | Build flags, BDD, parallel/sequential, builders, testify |
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
        ├── golang.md
        ├── go/
        │   ├── api-design.md
        │   ├── controllers.md
        │   ├── database.md
        │   ├── dependency-injection.md
        │   ├── repository-testing.md
        │   └── testing.md
        ├── commit-changelog.md
        ├── project-onboarding.md
        └── terra-cli.md
```

## Roadmap

- [ ] Java backend standards
- [ ] TypeScript backend standards
- [ ] TypeScript frontend standards
- [ ] React standards

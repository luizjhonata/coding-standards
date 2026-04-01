---
paths:
  - "**/*.go"
---

# Go Backend Standards

## Go Proverbs

Follow the [Go Proverbs](https://go-proverbs.github.io/) as guiding principles:

- The bigger the interface, the weaker the abstraction.
- Make the zero value useful.
- A little copying is better than a little dependency.
- Clear is better than clever.
- Errors are values — don't just check errors, handle them gracefully.
- Don't communicate by sharing memory, share memory by communicating.

## Go Architecture

Go-specific implementation of Clean Architecture + DDD:

- Layer flow: Controllers (Gin) → Commands → Entities + Repository Interfaces → Infrastructure
- Infrastructure models (DTOs for external sources) are prefixed with the tool name: `PgxUser`, `AwsFile`, `ApiDocument`
- No `json`, `gorm`, or other tags inside entity structs — tags are restricted to infrastructure DTOs (requests, responses, models)
- **Dependency injection**: existing projects use Google Wire (`container.go` per package, `make wire` to regenerate); new projects use manual constructor injection (no framework)

```
internal/{feature}/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── commands/
│   └── services/
├── infrastructure/
│   ├── controllers/
│   ├── repositories/
│   ├── mappers/
│   ├── requests/
│   └── responses/
└── container.go
```

## Naming

- **Files**: `snake_case` for all `.go` files (e.g., `list_users_command.go`, `pgx_users_repository.go`)
- **Packages**: lowercase single word
- **Interfaces**: descriptive + behavior (`PlaybookRepository`)
- **Method receivers**: one/two letter abbreviation of the type (`c` for `Command`, `r` for `Repository`, `m` for `Mapper`) — never `self`, `this`, or `me`; must be consistent across all methods of the same type
- GoDoc comments must start with the name of the element being documented

## Quality

- Functions: max 20 lines preferred, 100 hard limit
- Max file length 500 lines, max 5 parameters per function — if more are needed, group into a struct
- One main type per file, `*_test.go` in same package
- Map lookup over switch-case for 1-to-1 value mappings
- Use `mapstructure.Decode()` for similar struct mapping (nil-check, log errors at ERROR)

## Type System

- Accept interfaces as parameters, return concrete structs
- Keep interfaces small and focused — only the methods the consumer needs
- Place interfaces in the consumer package (domain layer), not the provider
- Never use `any`/`interface{}` as catch-all function parameters — define a proper interface or use generics with type constraints
- Use generics (Go 1.18+) only for genuine duplication across multiple types — not for single-type operations
- Prefer type switches over chained type assertions

## Import Ordering

Use `goimports` to enforce three groups separated by blank lines:

1. Standard library
2. Third-party packages
3. Application packages

## Error Handling and Logging

- Always import Logrus with the alias `logger`: `import logger "github.com/sirupsen/logrus"` (lowercase path only)
- Structured logging with `logger.WithFields(logger.Fields{...})`
- Never use standard `log` package or `fmt.Println` for application logging
- Always wrap errors: `fmt.Errorf("failed to X: %w", err)`
- Use `errors.New()` when no wrapping needed (perfsprint rule)
- Panic recovery with `defer handlePanic()` + `recover()` in main

## Lint Standards (golangci-lint)

Run `make lint` before committing. Key rules:

- **errorlint**: `errors.Is()`/`errors.As()`, not `==` — **funlen**: max 100 lines
- **godot**: comments end with period — **godoclint**: GoDoc starts with symbol name, `[time.Time]` link syntax
- **golines**: wrap long function params — **mnd**: named constants, no magic numbers
- **govet**: no variable shadowing — **funcorder**: constructors before methods
- **modernize**: `any` over `interface{}`, `slices.Contains`, `fmt.Appendf`, `omitzero` for nested struct JSON
- **embeddedstructfieldcheck**: blank line between embedded and regular fields
- **gosec G117**: `//nolint:gosec // G117 - config field` for config struct fields
- Use `//nolint` sparingly, always with justification

## SonarQube Essentials

- Coverage >= 80%, branch coverage >= 70%, duplication < 3%, tech debt < 5%
- All ratings (Maintainability/Reliability/Security): A
- **go:S1192 (MANDATORY)**: extract string literals duplicated 3+ times into constants (including tests)
- Test functions MUST use underscores: `TestMethod_Scenario_Result` (go:S100 disabled for `*_test.go`)

## Security (Horusec)

- ALWAYS ask user confirmation before fixing Horusec-reported issues
- Parameterized queries only — validate all inputs — don't expose internal errors
- Use `#nosec` / `//nolint:gosec` with justification

## Quality Checks Pipeline

Run before any `git push`. Each step must pass before the next:

```bash
make lint && make test && make sast
```

Note: the correct target is `make test` (NOT `make tests`).

Detailed testing conventions (build flags, BDD structure, parallel/sequential, builders, testify) are in `.claude/rules/go/testing.md` — loaded automatically when editing test files.

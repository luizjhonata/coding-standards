# Go Backend Standards

These rules apply to all Go backend projects when working with `*.go` files, `Makefile`, and `CHANGELOG.md`.

## Go Proverbs

Follow the [Go Proverbs](https://go-proverbs.github.io/) as guiding principles:

- The bigger the interface, the weaker the abstraction.
- Make the zero value useful.
- A little copying is better than a little dependency.
- Clear is better than clever.
- Errors are values — don't just check errors, handle them gracefully.
- Don't communicate by sharing memory, share memory by communicating.

## Language

All code comments, GoDoc, log messages, error messages, commit messages, variable names, and documentation MUST be in English. GoDoc comments must start with the name of the element being documented.

## Architecture (Clean Architecture + DDD)

Strict layer separation: Controllers (Gin) → Commands (Application) → Entities + Repository Interfaces (Domain) → Infrastructure (DB, HTTP, APIs).

- Domain layer MUST NOT import infrastructure packages
- Controllers MUST NOT contain business logic
- Interfaces in domain layer, implementations in infrastructure
- Prefer Rich Domain Models over Anemic — business logic belongs inside entities and value objects, not in service layers
- Entities MUST validate their own invariants on construction
- Entities MUST be framework-agnostic — no `json`, `gorm`, or other tags inside entity structs; tags are restricted to infrastructure DTOs (requests, responses, models)
- Use value objects for concepts with equality by value
- Infrastructure models (DTOs for external sources) are prefixed with the tool name: `PgxUser`, `AwsFile`, `ApiDocument`
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

## Design Principles

- Follow DRY, KISS, YAGNI, and SRP — if you need "and" to describe a function, split it
- Prefer pure functions: never modify input parameters (slices, maps, pointers) — return new values instead
- Functions with side effects MUST be clearly identifiable by name (e.g., `saveOrder`, `sendNotification`)
- Separate pure functions from functions with side effects
- Prefer immutable data structures — never modify global state
- Depend on abstractions, never on concrete implementations
- Before writing new code, check if equivalent logic already exists in the codebase

## Code Style

### Naming

- **Files**: `snake_case` for all `.go` files (e.g., `list_users_command.go`, `pgx_users_repository.go`)
- **Packages**: lowercase single word — **Interfaces**: descriptive + behavior (`PlaybookRepository`)
- **Controllers**: action + Controller — **Commands**: action + Command
- **Entities**: singular nouns — **DTOs**: purpose + DTO (`CreateUserRequest`)
- **Mappers**: `Map` + source + `To` + target
- **Booleans**: must read as questions — `isActive`, `hasPermission`, `canRetry`
- **Method receivers**: one/two letter abbreviation of the type (`c` for `Command`, `r` for `Repository`, `m` for `Mapper`) — never `self`, `this`, or `me`; must be consistent across all methods of the same type
- **Repository methods**: follow the vocabulary `FindBy`, `FindAllBy`, `Has` (boolean), `Save`, `SaveAll`, `DeleteBy`
- Names must be self-explanatory — if a comment is needed to explain it, the name is wrong
- Short names in short scopes, descriptive names in long scopes

### Quality

- Functions: max 20 lines preferred, 100 hard limit, max cognitive complexity 15
- Max 3 nesting levels, use early returns
- Max file length 500 lines, max 5 parameters per function — if more are needed, group into a struct
- Avoid boolean flags as parameters — prefer two separate functions
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
- Structured logging with `logger.WithFields(logger.Fields{...})` — never log sensitive data
- Never use standard `log` package or `fmt.Println` for application logging
- Always wrap errors: `fmt.Errorf("failed to X: %w", err)`
- Use `errors.New()` when no wrapping needed (perfsprint rule)
- Panic recovery with `defer handlePanic()` + `recover()` in main
- Exponential backoff for external service calls

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

## Commit and CHANGELOG

- Conventional format: `type(TICKET-XXXX): concise imperative description` with `Signed-off-by` trailer
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. Max 72 chars title, imperative mood, lowercase after colon
- NEVER squash commits without explicit user confirmation. NEVER force push without explicit request
- Detailed commit and CHANGELOG workflow in `.claude/rules/commit-changelog.md`

## Development Workflow

- Always discuss plans before implementation — do not start coding without alignment
- Work in small, iterative increments
- Feature implementation order: domain types → tests → implementation → infrastructure
- Follow TDD (Red-Green-Refactor):
  1. Write a failing test first with explicit inputs and expected outputs
  2. Implement the minimum code to make the test pass
  3. Refactor while keeping tests green
- No production code without a corresponding test
- Detailed testing conventions (build flags, BDD structure, parallel/sequential, builders, testify) are in `.claude/rules/testing.md` — loaded automatically when editing test files

## Agent and Tool Usage

- Prefer direct tools (Read, Grep, Glob, WebFetch) when the task is simple — agents add overhead and can stall on external calls
- Use parallel agents only for genuinely complex or independent tasks that benefit from concurrent execution
- Never re-fetch information that is already available in the conversation
- Never launch an agent and go silent — always tell the user what is running and why
- If an agent stalls or fails, inform the user with the reason for the slowness (e.g., blocked on external call, timeout), then retry the task yourself using direct tool calls

## Self-Review Checklist (before committing)

- Is there a test covering the main scenario and at least one error scenario?
- Is any literal repeated more than 3 times?
- Does any function exceed the parameter, line, or complexity limits?
- Is there duplicated logic that could be extracted?
- Do names communicate intent without needing a comment?
- Are errors being handled explicitly?

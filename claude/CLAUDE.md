# Coding Standards

These rules apply to all projects regardless of language or framework.

## Language

All code comments, documentation, log messages, error messages, commit messages, variable names, and documentation MUST be in English.

## Architecture (Clean Architecture + DDD)

Strict layer separation: Controllers → Commands (Application) → Entities + Repository Interfaces (Domain) → Infrastructure (DB, HTTP, APIs).

- Domain layer MUST NOT import infrastructure packages
- Controllers MUST NOT contain business logic
- Interfaces in domain layer, implementations in infrastructure
- Prefer Rich Domain Models over Anemic — business logic belongs inside entities and value objects, not in service layers
- Entities MUST validate their own invariants on construction
- Entities MUST be framework-agnostic — no framework-specific annotations or tags inside entity structs; those belong in infrastructure DTOs
- Use value objects for concepts with equality by value
- Depend on abstractions, never on concrete implementations

## Design Principles

- Follow DRY, KISS, YAGNI, and SRP — if you need "and" to describe a function, split it
- Prefer pure functions: never modify input parameters — return new values instead
- Functions with side effects MUST be clearly identifiable by name (e.g., `saveOrder`, `sendNotification`)
- Separate pure functions from functions with side effects
- Prefer immutable data structures — never modify global state
- Before writing new code, check if equivalent logic already exists in the codebase

## Naming Conventions

- **Controllers**: action + Controller — **Commands**: action + Command
- **Entities**: singular nouns — **DTOs**: purpose + DTO (`CreateUserRequest`)
- **Mappers**: `Map` + source + `To` + target
- **Repository methods**: follow the vocabulary `FindBy`, `FindAllBy`, `Has` (boolean), `Save`, `SaveAll`, `DeleteBy`
- **Booleans**: must read as questions — `isActive`, `hasPermission`, `canRetry`
- Names must be self-explanatory — if a comment is needed to explain it, the name is wrong
- Short names in short scopes, descriptive names in long scopes

## Code Quality

- Max cognitive complexity 15
- Max 3 nesting levels, use early returns
- Avoid boolean flags as parameters — prefer two separate functions

## Error Handling

- Always handle errors explicitly — never silently ignore or discard them
- Wrap errors with context so the origin is traceable
- Use structured logging with contextual fields — never log sensitive data
- Exponential backoff for external service calls

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

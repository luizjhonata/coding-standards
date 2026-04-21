# Coding Standards

These rules apply to all projects regardless of language or framework.

## Language

All code comments, documentation, log messages, error messages, commit messages, variable names, PR descriptions, Jira tickets, and any content in repositories or external systems MUST be in English.

The only exception is direct conversation with the user, which follows the language the user writes in.

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

## Git Conventions

- Do NOT add Co-Authored-By trailer to commits — only Signed-off-by
- Branch names: `type/TICKET-ID` when a ticket exists (e.g., `feat/DS-4639`, `fix/DS-4640`). Without a ticket: `type/scope` (e.g., `feat/add-logs`, `fix/input-mask`). Types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`
- Use SSH (not HTTPS) for cloning repositories
- Check actual default branch (main/master) before assuming
- Use hyphens in directory and repository names (not underscores)

## Commit and CHANGELOG

- Conventional format: `type(SCOPE): concise imperative description` with `Signed-off-by` trailer
- SCOPE is the ticket ID when available (e.g., `DS-4639`), otherwise a short descriptive scope
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Max 72 chars title, imperative mood, do not capitalize first letter after colon, no period at the end
- Wrap code references in backticks (e.g., `setAnyThing`)
- Multiple tickets: `fix(DS-567+DS-568): description`
- Long commits: subject line + blank line + body with bullet points
- Breaking changes must be flagged in three places: commit footer (`**BREAKING CHANGE:**`), CHANGELOG.md, and PR description
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

## External Systems

NEVER post, create, or modify content in external systems (Jira, Azure DevOps, Confluence, or any other) without showing a complete draft first and receiving explicit approval to proceed.

- Always present the full draft content before executing any create/update action
- Wait for explicit confirmation before acting
- When updating Jira, prefer updating the description over adding comments for substantive changes
- Use Atlassian MCP for Jira/Confluence, Azure DevOps MCP for DevOps repos/PRs/pipelines

## Scope & Focus

- Fix exactly what was asked — do not expand into adjacent issues or refactors
- When the request is ambiguous, ASK for clarification instead of assuming
- Never fix lint, SonarQube, or other issues beyond what was explicitly requested
- If a fix requires changes outside the expected scope, STOP and list the planned changes for approval before proceeding

## Agent and Tool Usage

- Prefer direct tools (Read, Grep, Glob, WebFetch) when the task is simple — agents add overhead and can stall on external calls
- Use parallel agents only for genuinely complex or independent tasks that benefit from concurrent execution
- Never re-fetch information that is already available in the conversation
- Never launch an agent and go silent — always tell the user what is running and why
- If an agent stalls or fails, inform the user with the reason for the slowness (e.g., blocked on external call, timeout), then retry the task yourself using direct tool calls
- Narrate progress between tool calls — never go silent during multi-step operations
- Explain the purpose of each CLI command before running it, and summarize the result
- Prefer direct action first; only explore or investigate if the direct approach fails
- When running lint with --fix, explicitly report what was auto-corrected so the user knows to stage those changes

## Self-Review Checklist (before committing)

- Is there a test covering the main scenario and at least one error scenario?
- Is any literal repeated more than 3 times?
- Does any function exceed the parameter, line, or complexity limits?
- Is there duplicated logic that could be extracted?
- Do names communicate intent without needing a comment?
- Are errors being handled explicitly?

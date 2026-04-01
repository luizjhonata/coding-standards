---
paths:
  - "README.md"
  - "main.go"
  - "go.mod"
  - "cmd/**/*.go"
  - "Dockerfile"
  - "docker-compose*.yml"
---

# Project Onboarding and Documentation

When asked to explore, explain, or document a project, follow this workflow.

## Exploration

1. Read key files: `main.go` (or entry point), `go.mod`, `Makefile`, `Dockerfile`, config files, route registration
2. Map architecture: packages, layers, external deps, data flow
3. Identify runtime: Lambda, container (Docker), CLI, or HTTP server

## Documentation Structure (for README.md)

1. **Overview**: purpose, problem solved, runtime model
2. **Architecture**: packages, layers, data flow, external deps
3. **Mermaid Diagram**:
   ```mermaid
   flowchart TD
       A[HTTP Request] --> B[Controller]
       B --> C[Command]
       C --> D[Repository]
       D --> E[(Database)]
   ```
4. **Configuration**: env vars, config files, secrets, defaults
5. **Routes/Endpoints**: method, path, description
6. **Local Development**: build/run instructions, prerequisites
7. **Sample Data**: event/request files when applicable

## Security Checks

Ensure `.gitignore` includes: `env.json`, `.env`, `*.pem`, `credentials.json`.
Never commit secrets or API keys in sample files — use placeholders.

## CHANGELOG

When documentation changes are significant, add a CHANGELOG entry under `### Added` or `### Changed` following commit-changelog conventions.

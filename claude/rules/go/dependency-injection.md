---
paths:
  - "**/container.go"
  - "**/wire.go"
  - "**/wire_gen.go"
---

# Dependency Injection

## Strategy

- **Existing projects with Wire**: follow the Wire patterns below
- **New projects**: use manual constructor injection — no DI framework

## Google Wire (existing projects only)

### Container Structure

Create `container.go` in each package that needs dependency injection:

```go
//nolint:gochecknoglobals // requirement for container
var Container = wire.NewSet(
    NewConcreteType,
    wire.Bind(new(Interface), new(*ConcreteType)),
)
```

### Multiple Dependencies

```go
//nolint:gochecknoglobals // requirement for container
var Container = wire.NewSet(
    NewServiceA,
    NewServiceB,
    wire.Bind(new(ServiceAInterface), new(*ServiceA)),
    wire.Bind(new(ServiceBInterface), new(*ServiceB)),
)
```

### Rules

- Use `wire.NewSet()` for grouping dependencies
- Use `wire.Bind()` for interface-to-implementation binding
- Always add `//nolint:gochecknoglobals // requirement for container`
- Wire files should be excluded from coverage and duplication analysis
- Regenerate wire files after changes: `make wire`

## Manual DI (new projects)

### Constructor Injection

Pass dependencies as constructor parameters — no global state, no framework:

```go
func NewListUsersCommand(repo repositories.UsersRepository) *ListUsersCommand {
    return &ListUsersCommand{repo: repo}
}
```

### Wiring

Wire everything in `main.go` or a dedicated `bootstrap.go`:

```go
func main() {
    db := setupDatabase()
    repo := repositories.NewPgxUsersRepository(db)
    command := commands.NewListUsersCommand(repo)
    controller := controllers.NewListUsersController(command)
    // register routes...
}
```

### Rules

- All dependencies passed via constructor — no package-level vars, no init()
- Each layer only depends on interfaces from the layer below
- No service locator pattern — explicit wiring only

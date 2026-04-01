---
paths:
  - "**/controllers/**/*.go"
---

# Controller Patterns (Gin Framework)

## Structure

```go
type ListPlaybooksController struct {
    gcontext *gin.Context
    command  commands.ListPlaybooks
}

func (c ListPlaybooksController) GetBind() core.ControllerBind {
    return core.ControllerBind{
        Method:       http.MethodPost,
        Version:      "v1",
        RelativePath: "/playbooks",
    }
}

func (c ListPlaybooksController) GetClaims() []string {
    return []string{string(global.Customer)}
}

func (c ListPlaybooksController) Execute(gcontext *gin.Context) {
    c.gcontext = gcontext
    listeners := commands.ListPlaybooksCommandListeners{
        OnSuccess: c.onSuccess,
        OnError:   c.onError,
    }
    c.command.Execute(listeners)
}
```

## Rules

- Implement `core.Controller[*gin.Context]` interface with `GetBind()`, `GetClaims()`, `Execute()`
- Store `*gin.Context` as field for access in callbacks
- Use command pattern — never put business logic in controller
- Implement listeners pattern for success/error handling

## Callback Methods

```go
func (c *ListPlaybooksController) onSuccess(playbooks []entities.Playbook) {
    responses := make([]responses.PlaybookResponse, len(playbooks))
    for i, playbook := range playbooks {
        responses[i] = *mappers.MapPlaybookToResponse(&playbook)
    }
    c.gcontext.JSON(http.StatusOK, responses)
}

func (c *ListPlaybooksController) onError(err error) {
    logger.Errorf("failed to list playbooks: %s", err)
    c.gcontext.JSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
}
```

## Swagger Documentation

Include comprehensive annotations for ALL endpoints:

```go
// Execute List all Playbooks Available for the Customer Cluster.
//
// @BasePath /v1/playbooks
// @Security BearerAuth
// @Summary List all Playbooks Available for the Customer Cluster
// @Description List all Playbooks Available for the Customer Cluster
// @Tags playbooks
// @Accept json
// @Produce json
// @Success 200 {object} []responses.PlaybookResponse
// @Failure 401 {object} failure.ValidationResponse "Unauthorized"
// @Failure 403 {object} failure.ValidationResponse "Permission denied"
// @Failure 500 {object} failure.ValidationResponse
// @Router /v1/playbooks [get]
func (c ListPlaybooksController) Execute(gcontext *gin.Context) {}
```

Required annotations: `@BasePath`, `@Security`, `@Summary`, `@Description`, `@Tags`, `@Accept`, `@Produce`, `@Success`, `@Failure`, `@Router`.

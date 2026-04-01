---
paths:
  - "**/*_test.go"
  - "**/test/**/*.go"
  - "**/doubles/**/*.go"
  - "**/builders/**/*.go"
---

# Testing Standards

## Build Tags

```go
//go:build unit        // Unit tests only
//go:build integration // Integration tests only
//go:build integration || unit || test // All tests
```

## Given-When-Then Pattern (MANDATORY)

ALL tests MUST use lowercase comments. No exceptions.

```go
func TestExample(t *testing.T) {
    // given
    // setup

    // when
    // execute

    // then
    // assert
}
```

Never use `// Given`, `// Setup`, `// Test`, `// Assertions`.

## Test Data Builders (MANDATORY)

- Use builder pattern for ALL test data — never `map[string]interface{}`
- Builders MUST use `gofakeit` for default values — never hardcoded
- Location: `test/{module}/domain/builders/` and `test/{module}/infrastructure/builders/`
- Fluent API: all `With*()` methods return `*Builder` for chaining

```go
import "github.com/brianvoe/gofakeit/v6"

type AlertBuilder struct {
    alert *entities.Alert
}

func NewAlertBuilder() *AlertBuilder {
    return &AlertBuilder{
        alert: &entities.Alert{
            AlertID:    int64(gofakeit.IntRange(1, 1000)),
            AlertUUID:  gofakeit.UUID(),
            AlertTitle: gofakeit.Sentence(3),
        },
    }
}

func (b *AlertBuilder) WithID(id int64) *AlertBuilder {
    b.alert.AlertID = id
    return b
}

func (b *AlertBuilder) Build() entities.Alert {
    return *b.alert
}
```

Common gofakeit functions: `UUID()`, `IntRange()`, `Sentence()`, `Name()`, `Username()`, `Email()`, `Date()`, `URL()`, `IPv4Address()`, `RandomString()`.

## Command Stubs

Create in `test/{module}/domain/commands/doubles/` with fluent API:

```go
type GetAlertsCommandStub struct {
    callback func(ctx context.Context, req *requests.GetAlertsRequest, listeners commands.GetAlertsCommandListeners)
}

func NewGetAlertsCommandStub() *GetAlertsCommandStub {
    return &GetAlertsCommandStub{}
}

func (s *GetAlertsCommandStub) WithOnSuccess(alertList *entities.AlertList) *GetAlertsCommandStub {
    s.callback = func(_ context.Context, _ *requests.GetAlertsRequest, listeners commands.GetAlertsCommandListeners) {
        listeners.OnSuccess(alertList)
    }
    return s
}

func (s *GetAlertsCommandStub) WithOnError(err error) *GetAlertsCommandStub {
    s.callback = func(_ context.Context, _ *requests.GetAlertsRequest, listeners commands.GetAlertsCommandListeners) {
        listeners.OnError(err)
    }
    return s
}
```

## Assertions

- `testify/require` for critical assertions (test stops on failure)
- `testify/assert` for non-critical assertions
- Compare entire objects: `assert.Equal(t, expectedAlert, result.Alert)`
- Avoid multiple individual field assertions for complex objects

## Test File Organization

- Hard limit: 500 lines per test file (recommended 200-350)
- Split by responsibility: `*_success_test.go`, `*_errors_test.go`, `*_parsing_test.go`, `*_network_test.go`, `*_edge_cases_test.go`
- Or by feature: `*_create_test.go`, `*_read_test.go`, `*_update_test.go`, `*_delete_test.go`

## Controller Tests

- **Unit** (`//go:build unit`): Co-located `*_controller_test.go`, mock commands (not repositories), test HTTP layer only
- **Integration** (`//go:build integration`): Co-located `*_controller_integration_test.go`, real implementations

```go
//go:build unit
package controllers_test

func TestGetAlertsController(t *testing.T) {
    t.Run("should return OK (200) when alerts are fetched successfully", func(t *testing.T) {
        // given
        gin.SetMode(gin.TestMode)
        router := gin.New()
        alert := builders.NewAlertBuilder().WithID(1).WithTitle("Test Alert").Build()
        alertList := builders.NewAlertListBuilder().WithAlerts([]entities.Alert{alert}).Build()
        command := doubles.NewGetAlertsCommandStub().WithOnSuccess(alertList)
        controller := controllers.NewGetAlertsController(command)

        // when
        router.GET("/v1/iris/alerts", controller.Execute)
        req, err := http.NewRequest(http.MethodGet, "/v1/iris/alerts?page=1&per_page=10", nil)
        recorder := httptest.NewRecorder()
        router.ServeHTTP(recorder, req)

        // then
        require.NoError(t, err)
        assert.Equal(t, http.StatusOK, recorder.Code)
    })
}
```

## String Literal Duplication in Tests

Extract repeated strings (3+ times) into constants at the top of test files:

```go
const (
    testAPIKey    = "test-api-key-123"
    testUserEmail = "test@example.com"
)
```

Use camelCase for test constants.

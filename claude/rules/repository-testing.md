---
paths:
  - "**/*repository*_test.go"
  - "**/*_repository_test.go"
  - "**/repositories/**/*_test.go"
---

# Repository Testing Standards

## Anti-Patterns (NEVER do these)

### 1. Manual Map Construction
```go
// NEVER
alert := map[string]interface{}{
    "alert_id": 1,
    "alert_title": "Test Alert",
}
```
Use builder pattern instead.

### 2. Multiple Individual Assertions
```go
// NEVER
assert.Equal(t, int64(1), alert.AlertID)
assert.Equal(t, "Test Alert", alert.AlertTitle)
// ... 20+ more
```
Compare entire objects: `assert.Equal(t, expectedAlert, result.Alert)`

### 3. Manual Response Mapping
```go
// NEVER
response := responses.APIResponse{
    Data: responses.APIResponseData{
        Alerts: []map[string]interface{}{alertMap},
    },
}
```
Use typed responses with concrete types.

## Required Pattern

```go
func TestRepository_Method_Scenario(t *testing.T) {
    t.Run("should do something when condition", func(t *testing.T) {
        // given
        expectedEntity := builders.NewEntityBuilder().
            WithField1("value1").
            Build()

        server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            response := responses.APIResponse{
                Data: responses.APIResponseData{
                    Entities: []entities.Entity{expectedEntity},
                },
            }
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusOK)
            json.NewEncoder(w).Encode(response)
        }))
        defer server.Close()

        repo := repositories.NewRepository(settings)

        // when
        result, err := repo.Method(context.Background(), request)

        // then
        require.NoError(t, err)
        require.NotNil(t, result)
        assert.Equal(t, expectedEntity, result.Entity)
    })
}
```

## Builder Requirements

Every entity builder MUST have:

1. Constructor with `gofakeit` defaults: `NewEntityBuilder() *EntityBuilder`
2. Field setters: `WithFieldName(value) *EntityBuilder`
3. Nested object setters: `WithNestedObject(obj) *EntityBuilder`
4. Collection setters: `WithItems(items) *EntityBuilder`
5. Build method: `Build() Entity`

## Single Source of Truth

- Build expected data once with builder
- Use same data in mock response
- Assert against same data

```go
expected := builders.NewAlertBuilder().WithID(1).Build()
response := responses.APIResponse{Data: responses.APIResponseData{Alerts: []entities.Alert{expected}}}
assert.Equal(t, expected, result.Alert)
```

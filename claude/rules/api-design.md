---
paths:
  - "**/controllers/**/*.go"
  - "**/requests/**/*.go"
  - "**/responses/**/*.go"
  - "**/mappers/**/*.go"
---

# API Design and Documentation

## RESTful Conventions

- Proper HTTP methods: GET, POST, PUT, DELETE
- Resource-based URLs: `/v1/playbooks`, `/v1/users/{id}`
- URL versioning with `/v1/` prefix

```
GET    /v1/playbooks           # List
GET    /v1/playbooks/{id}      # Get
POST   /v1/playbooks           # Create
PUT    /v1/playbooks/{id}      # Update
DELETE /v1/playbooks/{id}      # Delete
```

## Request DTOs

```go
type CreatePlaybookRequest struct {
    Name        string   `json:"name" validate:"required,min=2,max=255"`
    Description string   `json:"description" validate:"max=1000"`
    URL         string   `json:"url" validate:"required,url"`
    Tags        []string `json:"tags" validate:"dive,min=1,max=50"`
}

func (r *CreatePlaybookRequest) Validate() error {
    validate := validator.New()
    return validate.Struct(r)
}
```

## Response DTOs

```go
type PlaybookResponse struct {
    ID          int64     `json:"id"`
    Name        string    `json:"name"`
    Description string    `json:"description"`
    URL         string    `json:"url"`
    Tags        []string  `json:"tags"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}
```

## Mappers

```go
func MapPlaybookToResponse(playbook *entities.Playbook) *responses.PlaybookResponse {
    if playbook == nil {
        return nil
    }
    return &responses.PlaybookResponse{
        ID: playbook.ID, Name: playbook.Name,
        Description: playbook.Description, URL: playbook.URL,
        Tags: playbook.Tags, CreatedAt: playbook.CreatedAt, UpdatedAt: playbook.UpdatedAt,
    }
}

func MapCreateRequestToEntity(req *requests.CreatePlaybookRequest) *entities.Playbook {
    return &entities.Playbook{
        Name: req.Name, Description: req.Description, URL: req.URL, Tags: req.Tags,
    }
}
```

## Pagination

```go
type PaginationParams struct {
    Page  int `form:"page" binding:"min=1" default:"1"`
    Limit int `form:"limit" binding:"min=1,max=100" default:"10"`
}

type PaginatedResponse struct {
    Data       interface{} `json:"data"`
    Pagination Pagination  `json:"pagination"`
}

type Pagination struct {
    Page       int  `json:"page"`
    Limit      int  `json:"limit"`
    Total      int  `json:"total"`
    TotalPages int  `json:"total_pages"`
    HasNext    bool `json:"has_next"`
    HasPrev    bool `json:"has_prev"`
}
```

## Error Response Format

```go
type ErrorResponse struct {
    Error   string            `json:"error"`
    Message string            `json:"message"`
    Code    string            `json:"code,omitempty"`
    Details map[string]string `json:"details,omitempty"`
}
```

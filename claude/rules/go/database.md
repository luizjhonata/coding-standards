---
paths:
  - "**/repositories/**/*.go"
  - "**/migrations/**/*.sql"
  - "db/**/*.sql"
---

# Database and Repository Patterns

## Domain Interface

```go
// internal/playbooks/domain/repositories/playbook_repository.go
type PlaybookRepository interface {
    ListPlaybooks() ([]entities.Playbook, error)
    CreatePlaybook(inputEntity entities.Playbook) error
    GetPlaybookByID(id int64) (*entities.Playbook, error)
    UpdatePlaybook(playbook entities.Playbook) error
    DeletePlaybook(id int64) error
}
```

## Infrastructure Implementation

```go
type PlaybookRepository struct {
    db *sqlx.DB
}

func NewPlaybookRepository(db *sqlx.DB) *PlaybookRepository {
    return &PlaybookRepository{db: db}
}

func (r *PlaybookRepository) ListPlaybooks() ([]entities.Playbook, error) {
    var playbooks []entities.Playbook
    query := `SELECT id, name, description, url, created_at FROM playbooks ORDER BY created_at DESC`
    err := r.db.Select(&playbooks, query)
    return playbooks, err
}

func (r *PlaybookRepository) CreatePlaybook(inputEntity entities.Playbook) error {
    query := `INSERT INTO playbooks (name, description, url) VALUES ($1, $2, $3) RETURNING id`
    return r.db.Get(&inputEntity.ID, query, inputEntity.Name, inputEntity.Description, inputEntity.URL)
}
```

## SQLx Query Patterns

```go
// Select multiple
err := r.db.Select(&playbooks, query, true)

// Select single
err := r.db.Get(&playbook, query, id)

// Insert with returning
err := r.db.Get(&id, query, name, description)

// Update
result, err := r.db.Exec(query, name, description, id)
```

## Transaction Handling

```go
tx, err := r.db.Beginx()
if err != nil {
    return fmt.Errorf("failed to begin transaction: %w", err)
}
defer tx.Rollback()

// ... operations with tx ...

return tx.Commit()
```

## Migrations (Goose)

Place in `db/migrations/`. Include both up and down.

```sql
-- 000001_create_playbooks_table.up.sql
CREATE TABLE playbooks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    url VARCHAR(500),
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 000001_create_playbooks_table.down.sql
DROP TABLE playbooks;
```

## Connection Pool

```go
const (
    maxOpenConns    = 25
    maxIdleConns    = 5
    connMaxLifetime = 5 * time.Minute
)

db.SetMaxOpenConns(maxOpenConns)
db.SetMaxIdleConns(maxIdleConns)
db.SetConnMaxLifetime(connMaxLifetime)
```

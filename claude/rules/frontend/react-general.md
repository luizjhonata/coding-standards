---
paths:
  - "**/*.tsx"
  - "**/*.ts"
---

# React / TypeScript / Styled Components Standards

## New Project Bootstrap

Before writing component code in a new React/TypeScript/Vite project, define the foundation:

1. **Folder structure** — establish the layout before the first component
2. **ESLint + Prettier** — configure from the start, not retroactively
3. **Testing setup** — Jest or Vitest configured and a first smoke test passing
4. **Styled-components** — co-located `styles.ts` pattern from day one

```
src/
  components/
    shared/            # reusable across pages
    pages/             # page-level components
  hooks/               # custom hooks
  services/            # API calls
  types/               # shared TypeScript types
```

If the project needs a design system later (theme provider, palette tokens, typography scale), add a `theme/` directory at that point — do not pre-create it.

## File Naming

- `snake_case` for all files (e.g., `my_component.tsx`, `use_my_hook.ts`, `styles.ts`)
- One main component per file
- Co-locate styles in `styles.ts` next to the component

## Styled Components

NEVER define styled components in component files. Always separate into `styles.ts`.

```
my_component/
  index.tsx       # component logic and JSX only
  styles.ts       # ALL styled components
```

### Theme Usage — Never Hardcode Colors

```typescript
// styles.ts
import styled from 'styled-components';

export const Container = styled.div`
  background-color: ${({theme}) => theme.palette.button.neutral};
  color: ${({theme}) => theme.palette.shades.lightest};
  gap: 16px;
  padding: 24px;
`;

// typed transient props (prefixed with $)
export const StatusText = styled.span<{$severity: 'low' | 'high' | 'critical'}>`
  color: ${({theme, $severity}) => theme.palette.severity[$severity]};
`;
```

Use `useTheme()` hook when theme values are needed in component logic, not just styled-components.

### Styling Rules

- No inline styles (`style={{ }}`) — create a styled-component
- No hardcoded colors — always use theme palette via `({theme}) => theme.palette.*`
- No `!important` — fix specificity or create a proper component
- No magic numbers — use standard spacing: 4, 8, 12, 16, 24, 32, 48
- Always check for existing components before creating new ones

## ESLint Rules

Zero errors, zero warnings. Run `yarn lint` before committing.

| Rule | Requirement |
|------|-------------|
| `max-lines` (210) | Split: hooks, sections, styled-components, helpers |
| `max-statements` (10) | Extract helper functions |
| `no-explicit-any` | Use `Record<string, unknown>` or define proper types |
| `no-inline-styles` | Use styled-components in `styles.ts` |
| `no-console` | Use `useState` for error state, framework logger on server |
| `no-floating-promises` | Prefix with `void` in `useEffect` |
| `no-restricted-imports` | Use absolute paths, no `../../` relative parents |
| `import/order` | Groups: (1) external, (2) absolute internal, (3) relative |
| `@cspell/spellchecker` | Add `/* cspell:words term */` at top of file |
| Zero `eslint-disable` | Fix the root cause, no exceptions |

## React State and Props

- No derived state in `useState` — use `useMemo` to derive directly
- No raw strings for state — use union types (`'loading' | 'error' | 'data'`)
- Group related state — single object or discriminated union instead of 3+ `useState`
- Composite props (>10) — group into config objects (`PaginationConfig`, `FilterConfig`)
- Object maps over if/else chains for conditional rendering
- Memoize expensive computations with `useMemo`, but don't over-memoize cheap ops

## Code Quality Patterns

- Object maps over if/else for value mappings
- Error handling: wrap async calls in try/catch, set error state
- No `dangerouslySetInnerHTML` — use `<HtmlDecoder />` or equivalent
- Reuse existing components before creating new ones
- One class per file for domain entities

## Testing

Tests live under `tests/`, mirroring the source tree. Split by concern when files approach the line limit:

- `*_rendering.test.tsx` — conditional rendering, empty states, loading states
- `*_interactions.test.tsx` — clicks, form submissions, callbacks
- `*_filters.test.tsx` — search, sort, pagination behavior

### Given / When / Then Pattern (mandatory)

```typescript
it('should show error when API fails', () => {
  // Given: a service that returns an error
  const stubService = jest.fn().mockRejectedValue(new Error('API error'));

  // When: the component renders
  const {getByText} = render(<MyComponent service={stubService} />);

  // Then: the error message is displayed
  expect(getByText('Something went wrong')).toBeInTheDocument();
});
```

### Test Quality Rules

- Tests verify **behavior**, not just rendering — each test should break if behavior changes
- Don't mock the thing you're testing — mock external dependencies only
- Use `mount` when `useEffect` drives behavior, `shallow` for simple render checks
- No `as any` in tests — use proper types, `Partial<T>`, or typed builders
- No direct helper tests — test helpers indirectly through consuming components
- Name test doubles correctly: `stub*` (returns data), `mock*` (asserts calls), `spy*` (records calls)

### SonarQube

- Coverage >= 80%, branch coverage >= 70%
- Duplication < 3%, tech debt < 5%
- All ratings (Maintainability/Reliability/Security): A

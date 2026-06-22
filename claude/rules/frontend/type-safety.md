---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---

# Type Safety

Rules to prevent unsafe type assumptions at runtime. Apply to both TypeScript
and JavaScript — TS has compile-time tools (generics, type guards) while JS
relies on runtime checks alone, but the principles are the same.

## Universal Rules (TS + JS)

### Never assume the shape of external data

Data from `JSON.parse`, API responses, `localStorage`, URL params, or any
system boundary is **untrusted**. Always validate before accessing properties.

```typescript
// wrong — trusts the shape blindly
const user = JSON.parse(raw);
return user.name;

// right — validate then narrow
const parsed: unknown = JSON.parse(raw);
if (typeof parsed !== 'object' || parsed === null || !('name' in parsed)) {
  return '';
}
return String(parsed.name);
```

### Use `unknown` in catch blocks, narrow with guards

Never assume the error type. Use `instanceof`, property checks, or library
helpers (`axios.isAxiosError()`) to narrow.

```typescript
// wrong
catch (error) {
  return error.message;
}

// right
catch (error: unknown) {
  if (error instanceof Error) return error.message;
  return 'Unknown error';
}
```

### Runtime type guards over blind property access

When narrowing `unknown` or polymorphic data, write a type guard function.
One `as` inside the guard is acceptable — zero `as` at call sites.

```typescript
function isErrorWithMessage(value: unknown): value is { message: string } {
  return typeof value === 'object' && value !== null && 'message' in value
    && typeof (value as Record<string, unknown>).message === 'string';
}
```

### Never mutate input data to fix its type

Return a new value instead of mutating the original to match the expected shape.

```typescript
// wrong — mutates in place
entries.forEach((e) => { e.status = e.status.toLowerCase(); });

// right — new array, no mutation
const normalized = entries.map((e) => ({ ...e, status: e.status.toLowerCase() }));
```

## TypeScript-Specific Rules

### `as` is a last resort, not a shortcut

`as` silences the compiler without runtime proof. Before using it:

1. Can you fix the source type? (generic parameter, return type, interface change)
2. Can you narrow with a type guard? (`instanceof`, `in`, `typeof`, custom guard)
3. Can you use a generic? (`function diff<T extends object>(a: T, b: T): Partial<T>`)

If none apply, the `as` must be immediately preceded by a runtime check that
justifies it, or live inside a type guard function.

### Legitimate `as` patterns (do not flag)

| Pattern | Why it's safe |
|---------|---------------|
| `as const` | Literal type narrowing, not a type assertion |
| `key as keyof T` inside `for...in` | TypeScript limitation — `Object.keys()` returns `string[]` |
| `as` inside type guard body | The guard provides runtime proof; callers are cast-free |
| `as T` after `Array.isArray` / `typeof` / `instanceof` | Compiler can't narrow but runtime already proved the type |
| `as ReadonlyArray<string>` on `as const` arrays for `.includes()` | TypeScript limitation — readonly tuple rejects broader `string` param |

### Forbidden `as` patterns (always fix)

| Pattern | Fix |
|---------|-----|
| `response as MyType` without validation | Add runtime check or make the generic explicit |
| `error as { message: string }` in catch | Use `instanceof Error` or a type guard |
| `as unknown as TargetType` double cast | Redesign — the types are fundamentally incompatible |
| `as any` | Never — use `unknown` and narrow |
| Redundant cast when interface already returns the correct type | Delete the cast |

### Prefer generics over caller-side casts

If multiple callers need `as T`, the function should accept `<T>` instead.

```typescript
// wrong — every caller casts
const diff = getObjectDiff(a as Record<string, unknown>, b as Record<string, unknown>) as Partial<MyType>;

// right — generic eliminates all casts
function getObjectDiff<T extends object>(original: T, updated: T): Partial<T> { ... }
const diff = getObjectDiff(a, b);
```

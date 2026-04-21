---
paths:
  - "public/modules/**/*"
  - "server/routes/**/*"
  - "common/domain/entities/*.ts"
  - "public/global/**/*"
  - "translations/*.json"
---

# OSD Plugin Standards (App Repo)

These rules apply specifically to the DarkSense OSD plugin (`opensearch-dashboards/plugins/app/`).

## Architecture

- **Module** = top-level sidebar section (e.g., "Security Alerts")
- **Sub-Module** = a page within a module (e.g., "Detection Rules", "List")
- Server routes **proxy** to external backends — OSD never talks to the DB directly

```
Browser (OSD) → OSD Server (Hapi) /api/module/trpc/* → External Backend
```

## Module Structure

```
public/modules/<module>/
├── module.ts                  # module definition (id, title, subModules[])
└── <submodule>/
    ├── app.tsx                # SubModule entry: renderApp + registration
    ├── index.ts               # entrypoint: registerServices + service type
    ├── presentation/
    │   └── view.tsx           # PageView + useSubScreenNavigation
    ├── content/
    │   ├── <screen>/index.tsx # main UI components
    │   └── styles.ts          # co-located styled-components
    └── domain/                # domain entities (optional)
```

## Registration Touchpoints

When adding a module or submodule, register in ALL of these:

| File | What |
|------|------|
| `common/domain/entities/all_modules.ts` | Module string ID |
| `common/domain/entities/all_sub_modules.ts` | Submodule string ID |
| `public/global/domain/entities/sub_module_title.ts` | Human-readable title |
| `public/global/domain/entities/sub_module_order.ts` | Nav order |
| `common/domain/entities/routes_mapper.ts` | Route ID for JWT auth |
| `public/modules/index.ts` | Import + add to `allModules` |
| `server/types.ts` + `server/container.ts` | Backend config |
| `server/routes/index.ts` | Route registration |
| `translations/en.json`, `pt-BR.json`, `ja-JP.json` | i18n keys |

## SubModule Entry Pattern

Every submodule exports a `SubModule` object and a `renderApp` function in `app.tsx`. Do NOT set any API base URL in app.tsx — backend access is via injected services from the entrypoint.

## View Pattern

Views use `PageView` + `useSubScreenNavigation` + `useTranslation`.

## HttpClient + Entrypoint

- Sub-module `index.ts`: export `registerServices(httpClient: HttpClient)` returning service objects
- Register in `public/modules/container.ts`
- Add to `Services` type and pass `HttpClient` in `public/container.ts`
- Components access via `usePluginContext().services.<service>`

## Server-Side Proxy Routes

- tRPC: GET/POST `/api/module/trpc/{procedure}` forwarding to backend
- ALWAYS use `validate: { params: schema.object({ procedure: schema.string() }) }` — never `validate: false` with path params
- Set `options: { xsrfRequired: false }` on POST routes
- Use `validateStatus: () => true` in axios
- REST alternative: `ProxyRouteBuilder` / `ProxyApiBuilder`

## Internationalization

Every user-facing string must use the translation hook. No hardcoded text in JSX.

```typescript
const translate = useTranslation('app.modules.<module>.<submodule>');
translate('key', {defaultMessage: 'Fallback'});
```

- Namespace: `app.modules.<module>.<submodule>`
- All three locale files: `en.json`, `pt-BR.json`, `ja-JP.json`
- Covers: labels, buttons, tooltips, errors, select options, column headers, empty states

## Styling

- Prefer EUI components — they inherit OSD dark theme
- Do NOT import `.css` files — OSD plugin has no CSS loader
- Custom CSS: runtime injection via `.ts` file that creates `<style>` and appends to `document.head`
- `import React from 'react'` in every `.tsx` file (OSD uses classic JSX transform)
- No `darkTheme` import in new code — use `({theme}) => theme.palette.*` in styled-components or `useTheme()` in logic

### Available Theme Tokens

```
theme.palette.shades    → empty, lightest, light, medium, dark, darkest, full
theme.palette.severity  → info, low, medium, high, critical, warning
theme.palette.button    → primary, accent, success, danger, neutral
theme.palette.input     → background, border
theme.palette.text      → subdued, buttonDefault
theme.palette.chart     → vis0 through vis8
```

### Babel Limitations

- Numeric separators (`30_000`) NOT supported — use `30000`
- `fetch` and `URLSearchParams` banned — use `axios`
- `Math.max(...array)` flagged — use `reduce` instead

## MVP Spec Template

Every MVP must include a spec document: copy `.docs/MVP_SPEC_TEMPLATE.md` to `.docs/{TICKET-KEY}_{feature-name}.md`, fill every section, commit with the feature branch.

## Common Pitfalls

| Issue | Fix |
|-------|-----|
| `Module not found` for package | Add dep to OSD root `node_modules` or create local shim |
| `React is not defined` | Add `import React from 'react'` to every `.tsx` |
| `Module parse failed` for CSS | Inject styles at runtime via TypeScript |
| `request.params` undefined | Use `validate: { params: schema.object(...) }`, never `validate: false` |
| XSRF errors on POST | Add `options: { xsrfRequired: false }` |

## OSD-Specific PR Requirements

In addition to the standard PR conventions in `CLAUDE.md`:

- Screenshots for every UI change
- MVP spec (`.docs/{TICKET-KEY}_{feature-name}.md`) committed on feature branch
- All strings use `useTranslation()` with keys in all 3 locale files

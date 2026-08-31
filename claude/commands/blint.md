Run lint only on files changed in the current branch compared to main. The goal is to validate what will be sent in a PR.

## Step 0: Resolve branch

If a branch name is provided as argument:

1. Check if the branch exists locally: `git rev-parse --verify <branch> 2>/dev/null`
2. If it does NOT exist locally, run `git fetch origin` to pull remote refs, then checkout: `git checkout <branch>`
3. If it already exists locally, just checkout: `git checkout <branch>`
4. Confirm you are on the correct branch with `git branch --show-current`.

If no argument is provided, use the current branch as-is.

## Step 1: Detect project type

- If `package.json` exists in the working directory → **Frontend** (JavaScript/TypeScript)
- If `go.mod` exists in the working directory → **Go**
- If both exist, ask the user which one to lint.
- If neither exists, report "Could not detect project type" and stop.

## Step 2: Run linter

### Frontend
1. Get changed files: `git diff --name-only main...HEAD -- '*.ts' '*.tsx' '*.js' '*.jsx'`
2. Filter out any files that no longer exist on disk (deleted files).
3. If no lintable files are found, report "No lintable files changed on this branch" and stop.
4. Run `npx eslint --fix` passing only the changed files.
5. Run `git diff --name-only` to detect which files were auto-fixed by `--fix`. Save this list for the report.
6. If there are still lint errors after --fix, read the files with remaining errors and fix them manually by editing the code.
7. Re-run `npx eslint` on those files to confirm all errors are resolved.
8. Repeat steps 6-7 until all lint errors are gone or you are stuck on an error you cannot resolve (in that case, ask the user for help).

### Go
1. Run `make lint`.
2. Run `git diff --name-only` to detect which files were auto-fixed by the linter. Save this list for the report.
3. If there are still lint errors, read the files with errors and fix them manually by editing the code.
4. Re-run `make lint` to confirm all errors are resolved.
5. Repeat steps 3-4 until all lint errors are gone or you are stuck on an error you cannot resolve (in that case, ask the user for help).
6. **Duplicated string literals (SonarQube `go:S1192` parity) — MANDATORY.** `make lint`'s shared `goconst` config does NOT match Sonar S1192 on TWO axes, so duplicated literals pass `make lint` but fail Sonar (this has caused repeated PR failures, in both test AND production files):
   - it excludes `_test.go` (and the merge cannot override that exclusion), and
   - `goconst` defaults `ignore-calls: true`, so it skips literals passed as function-call arguments (e.g. `fmt.Errorf("...")`, `t.Run("...")`) — exactly the strings Sonar flags.
   Validate explicitly with a goconst pass that fixes both gaps:
   - Write a temp config (e.g. `/tmp/goconst-s1192.yml`):
     ```yaml
     version: "2"
     linters:
       default: none
       enable: [goconst]
       settings:
         goconst:
           min-len: 10
           min-occurrences: 3
           ignore-calls: false
     ```
   - Run over the whole module INCLUDING tests (`golangci-lint` if on PATH, otherwise `./bin/golangci-lint`):
     `golangci-lint run -c /tmp/goconst-s1192.yml --tests ./... 2>&1 | grep goconst`
   - Get ALL changed Go files (not only tests): `git diff --name-only main...HEAD -- '*.go'`. For every finding located in one of those CHANGED files, extract the repeated literal into a package-level constant (a `const` block; for format strings keep the verb, e.g. `const fooMsg = "unsupported X: %s"`). Ignore findings only in files NOT changed on this branch (pre-existing/legacy).
   - Note: `goconst` counts per-package while Sonar counts per-file, so this gate is a strict SUPERSET of S1192 — it never misses an S1192 and may ask you to extract a few cross-file dups too (harmless DRY). Extract them; do not skip.
   - Re-run until there are no findings in changed files. Report each literal you turned into a constant.

## Step 3: Report results

**CRITICAL**: The report MUST clearly separate auto-fixed files from clean files. The user needs to know exactly what changed to stage those files for commit. If `--fix` corrected anything, NEVER report "0 errors" without listing what was auto-corrected.

Report format:

```
## Lint Results

**Auto-fixed by linter** (need to be staged):
- `file1.tsx` — import order
- `file2.ts` — formatting

**Manually fixed**:
- `file3.tsx` — max-statements violation (extracted helper function)

**Clean** (no changes needed):
- `file4.tsx`

**Still failing** (if any):
- `file5.tsx:42` — error description
```

For Go, the report MUST also include a line for the `go:S1192` test-literal check (step 6), e.g.:

```
**Test literals (go:S1192 parity)**: extracted `alert.change_status` → `testAlertPendingAction`  (or: "no duplicated literals in changed test files")
```

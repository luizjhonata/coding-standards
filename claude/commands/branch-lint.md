Run lint only on files changed in the current branch compared to main. The goal is to validate what will be sent in a PR.

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

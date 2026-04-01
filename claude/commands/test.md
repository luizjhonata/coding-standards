Run tests only for files changed in the current branch compared to main. The goal is to validate what will be sent in a PR.

## Step 1: Detect project type

- If `package.json` exists in the working directory → **Frontend** (JavaScript/TypeScript)
- If `go.mod` exists in the working directory → **Go**
- If both exist, ask the user which one to test.
- If neither exists, report "Could not detect project type" and stop.

## Step 2: Run tests

### Frontend

1. Get changed files: `git diff --name-only main...HEAD -- '*.ts' '*.tsx' '*.js' '*.jsx'`
2. Filter out any files that no longer exist on disk (deleted files).
3. If no changed files are found, report "No testable files changed on this branch" and stop.
4. Discover related test files using these strategies (combine all results, deduplicate):
   - **Direct test changes**: any changed file that is already a test file (`*.test.ts`, `*.test.tsx`) → include it directly.
   - **Mirror path**: for each changed source file under `public/`, build the mirror test path under `tests/public/` (e.g. `public/foo/bar.tsx` → `tests/public/foo/bar.test.tsx`; `public/foo/bar/index.tsx` → `tests/public/foo/bar/index.test.tsx`). Check if the file exists on disk.
   - **Grep for imports**: for each changed source file, extract its module import path (e.g. `public/modules/catalog/customer_clusters/schemas/node_validators`) and `grep -rl` for that import path inside `tests/` to find any test that imports the changed file. This catches indirect dependents like a test for a parent component that imports a changed child.
5. Filter out any discovered test files that no longer exist on disk.
6. If no related test files are found, report "No test files found for the changed files" and list the changed files so the user knows what was checked.
7. Run the discovered tests: `node ./tests/run_jest_tests.js --config ./tests/jest_config_public.js --testPathPattern="(test1|test2|...)"` where the pattern matches only the discovered test file paths. Use relative paths from the project root in the regex pattern.
8. Report which tests passed, which failed, and any errors.
9. If tests fail, read the failing test files and the related source files to understand and fix the issue. Then re-run only the failing tests to confirm the fix.
10. Repeat step 9 until all tests pass or you are stuck (in that case, ask the user for help).
11. **Post-fix lint check**: If any test files were modified during fix iterations (steps 9-10), run `npx eslint --fix <modified-test-files>` on them. After `--fix`, check `git diff` to see what was auto-fixed and report it. If lint errors remain that cannot be auto-fixed, fix them manually and re-run the failing tests to ensure they still pass.

### Go

1. Run `make test`.
2. If there are test failures, read the failing test files and related source files to understand and fix the issue.
3. Re-run `make test` to confirm all tests pass.
4. Repeat steps 2-3 until all tests pass or you are stuck (in that case, ask the user for help).

## Step 3: Report results

Report the final results: how many test files were run, how many tests passed/failed, which source files were covered by the tests, and which changed source files had no related tests found.

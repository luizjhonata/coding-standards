---
paths:
  - "**/*"
---

# Azure DevOps Pull Request Description

When creating PRs via the Azure DevOps MCP tool (`repo_create_pull_request` or `repo_update_pull_request`), replicate the default content that Azure DevOps auto-populates in the web UI.

## Description Structure

The PR description MUST include, in this order:

1. **Commit message**: full subject + body + `Signed-off-by` trailer (exactly as in `git log`)
2. **PR template**: the repo's `.azuredevops/pull_request_template.md` content (read it before creating the PR)
3. **Additional context**: summary, test plan, or any extra sections appended after

## Why

Azure DevOps auto-fills the commit message and PR template when creating via the web UI. The MCP API does not auto-fill, so we must replicate it manually. Omitting these defaults loses the commit signature trail and skips the quality checklist.

## Example

```markdown
fix(DS-1234): concise imperative description

- bullet point explaining the change

Signed-off-by: Author Name <author@example.com>

## :vertical_traffic_light: Quality checklist

- [x] Did you add the changes in the `CHANGELOG.md`?

## Summary

- Additional context about the change

## Test plan

- [ ] Verification steps
```

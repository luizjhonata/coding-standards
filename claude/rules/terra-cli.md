---
paths:
  - "**/*.tf"
  - "**/*.hcl"
  - "**/*.tfvars"
  - "environments/**/*"
---

# Terra CLI (Terraform/Terragrunt)

Use [terra](https://github.com/rios0rios0/terra) wrapper. NEVER invoke `terraform` or `terragrunt` directly.

## Commands

```bash
terra plan environments/03_dependency_track/dev
terra apply environments/03_dependency_track/dev
terra destroy environments/03_dependency_track/dev
terra format
terra init environments/03_dependency_track/dev
terra apply '-replace=null_resource.example[0]' environments/03_dependency_track/dev
```

## Safety Guard

NEVER run `terra apply` or `terra destroy` without explicit user confirmation. Before executing, ask for:
1. Environment path
2. Target stage (dev or prod)
3. Display full command and wait for approval

## Zsh Quoting

Arguments with brackets MUST be quoted:

```bash
# Correct
terra apply '-replace=null_resource.nvd_configuration[0]' environments/03_dependency_track/dev

# Wrong (zsh error: no matches found)
terra apply -replace=null_resource.nvd_configuration[0] environments/03_dependency_track/dev
```

## Parallel Execution

```bash
terra plan --parallel=4 environments/02_kubernetes
terra apply --parallel=4 --filter=dev,staging environments/02_kubernetes
```

## Environment Variables

In `.env` at project root with `TF_VAR_` prefix:

```bash
TERRA_CLOUD=azure
TF_VAR_environment=dev
TF_VAR_nvd_api_key="your-key"
```

## Post-Edit Quality Checks

After every Terraform file edit:

```bash
terra format
tflint --chdir . --recursive
```

Both must pass. If `tflint` reports issues, fix and re-run until clean.

## Pre-Push Quality Checks

```bash
terra format
tflint --chdir . --recursive
make test
make sast
```

All must pass before pushing. NEVER skip these checks.

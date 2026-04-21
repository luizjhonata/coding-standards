---
paths:
  - "**/*.tf"
  - "**/*.hcl"
  - "**/*.tfvars"
  - "**/helm/**/*"
  - "**/charts/**/*"
  - "**/values*.yaml"
---

# Infrastructure Standards (Terraform + Helm)

## General Principles

- Infrastructure changes MUST include cost analysis when creating or modifying resources
- All infrastructure MUST be defined in code — no manual console changes
- Security findings require both immediate CLI fix AND permanent IaC fix
- Document evidence commands for each remediation (audit trail)

## Terraform

### Project Structure

```
environments/
├── 01_base/
│   ├── dev/
│   │   └── terragrunt.hcl
│   └── prod/
│       └── terragrunt.hcl
├── 02_kubernetes/
└── 03_dependency_track/
modules/
├── my-module/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
```

### Naming

- Module directories: `kebab-case` (e.g., `helm-nginx-ingress`, `helm-opensearch-dashboards`)
- Resources: `snake_case` (e.g., `aws_s3_bucket.my_bucket`)
- Variables: `snake_case`, descriptive (e.g., `enable_multi_az`, `instance_class`)
- Outputs: `snake_case`, prefixed with resource context

### Conventions

- Pin provider and module versions explicitly
- Use `locals` for computed values, `variables` for inputs
- Tag all resources with at minimum: `Environment`, `Project`, `ManagedBy`
- Use `count` or `for_each` for conditional/repeated resources — prefer `for_each` for named resources
- CLI usage, quality checks and safety guards are defined in `terra-cli.md`

## Helm

### Chart Structure

```
helm-<name>/
├── Chart.yaml
├── values.yaml
├── values-dev.yaml
├── values-prod.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── _helpers.tpl
```

### Naming

- Chart directories: `helm-<name>` with kebab-case
- Template files: `kebab-case`
- Values keys: `camelCase` (Helm convention)

### Conventions

- Environment-specific values in `values-<env>.yaml`, not in the base `values.yaml`
- Use `_helpers.tpl` for reusable template functions
- Always define resource requests and limits
- Use `{{- include }}` over `{{ template }}` for whitespace control

## Cost Analysis

When proposing infrastructure changes, ALWAYS include:

- Current vs. proposed resource specifications
- Monthly cost estimate (use AWS/Azure pricing calculator)
- Cost comparison if upgrading/downgrading
- Whether the change affects reserved instances or savings plans

## Security

- No secrets in `.tf` files or `values.yaml` — use sealed secrets, external secrets, or vault
- Enable encryption at rest for all storage resources
- Restrict security groups and network policies to minimum required access
- Enable audit logging for all managed services

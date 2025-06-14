+++
authors = ["Artem Kozlenkov"]
title = "Infrastructure as Code Best Practices"
date = "2025-02-13"
description = "Key principles and tools for managing cloud infrastructure as code."
tags = ["IaC", "terraform", "bicep", "cloud", "automation"]
categories = ["Cloud", "Infrastructure"]
series = []
+++

## Use Case: Multi-Environment Infrastructure Deployment with Terraform Workspaces

### Scenario

A SaaS organization wants to manage its development, staging, and production cloud environments using the same Terraform codebase, but with separate state and configuration for each environment.

### Solution Overview

1. **Organize Terraform code into modules** for reusability.
2. **Leverage Terraform workspaces** to isolate state for each environment.
3. **Parameterize configuration** using input variables and workspace-specific files.
4. **Automate environment selection and deployment** with CI/CD.

#### Directory Structure Example

```
infrastructure/
  ├── main.tf
  ├── variables.tf
  ├── modules/
  │     └── network/
  │           └── main.tf
  ├── env/
        ├── dev.tfvars
        ├── staging.tfvars
        └── prod.tfvars
```

#### Example: Using Workspaces and Modules

```hcl
# main.tf
module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  # ... other variables
}
```

```bash
# Initialize and select workspace
terraform init
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file=env/dev.tfvars

terraform workspace new prod
terraform workspace select prod
terraform apply -var-file=env/prod.tfvars
```

#### CI/CD Integration Example (GitLab CI)

```yaml
stages:
  - deploy

deploy:
  image: hashicorp/terraform:1.5
  script:
    - terraform init
    - terraform workspace select $CI_ENVIRONMENT_NAME || terraform workspace new $CI_ENVIRONMENT_NAME
    - terraform apply -auto-approve -var-file=env/${CI_ENVIRONMENT_NAME}.tfvars
  only:
    - main
```

### Key Takeaways

- **Workspaces**: Separate state for each environment using Terraform workspaces.
- **Modularity**: Share and reuse code with modules.
- **Automation**: Integrate with CI/CD for rapid, reliable deployments.

This pattern simplifies environment management and improves consistency across your cloud infrastructure.
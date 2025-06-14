+++
authors = ["Artem Kozlenkov"]
title = "Best Practices für Infrastructure as Code"
date = "2025-02-13"
description = "Wichtige Prinzipien und Werkzeuge für das Management von Cloud-Infrastruktur als Code."
tags = ["IaC", "terraform", "bicep", "cloud", "automation"]
categories = ["Cloud", "Infrastructure"]
series = []
+++

## Anwendungsfall: Multi-Environment Infrastruktur-Bereitstellung mit Terraform Workspaces

### Szenario

Eine SaaS-Organisation möchte ihre Entwicklungs-, Staging- und Produktions-Cloud-Umgebungen mit derselben Terraform-Codebasis verwalten, jedoch mit getrenntem Zustand und Konfiguration für jede Umgebung.

### Lösungsübersicht

1. **Organisieren Sie Terraform-Code in Modulen** zur Wiederverwendbarkeit.
2. **Nutzen Sie Terraform Workspaces**, um den Zustand für jede Umgebung zu isolieren.
3. **Parametrisieren Sie die Konfiguration** mit Eingabevariablen und workspace-spezifischen Dateien.
4. **Automatisieren Sie die Umgebungswahl und Bereitstellung** mit CI/CD.

#### Beispiel für Verzeichnisstruktur

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

#### Beispiel: Verwendung von Workspaces und Modulen

```hcl
# main.tf
module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  # ... weitere Variablen
}
```

```bash
# Workspace initialisieren und auswählen
terraform init
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file=env/dev.tfvars

terraform workspace new prod
terraform workspace select prod
terraform apply -var-file=env/prod.tfvars
```

#### Beispiel für CI/CD-Integration (GitLab CI)

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

### Wichtige Erkenntnisse

- **Workspaces**: Trennen Sie den Zustand für jede Umgebung mit Terraform Workspaces.
- **Modularität**: Teilen und wiederverwenden Sie Code mit Modulen.
- **Automatisierung**: Integrieren Sie CI/CD für schnelle und zuverlässige Bereitstellungen.

Dieses Muster vereinfacht das Management von Umgebungen und verbessert die Konsistenz über Ihre Cloud-Infrastruktur hinweg.
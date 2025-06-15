<p align="center">
  <a href="#">
    <img src="images/logos/logotype-a.png" alt="Cody Portfolio Logo" width="600px" height="184px">
  </a>
</p>

# Hugo Coder Portfolio Theme

A customized Hugo theme tailored for personal portfolios and blogs, leveraging Azure static website hosting and Terraform automation. Showcase your work with a clean, responsive design, while automating deployments and infrastructure provisioning.

## Purpose

This fork adapts the original Hugo Coder theme to support:

- Static site hosting on Azure Blob Storage (`$web` container) with CI/CD.
- Infrastructure provisioning using Terraform for resource group, storage account, and service principal.
- Secret scanning via Gitleaks before deployment.
- Easy customization for portfolio sections and project showcases.

## Main Features

- Responsive, minimal blog & portfolio layout.
- Built-in Terraform configuration ([`main.tf`](main.tf:1)) for Azure resources.
- Deployment script ([`deploy_to_blob.sh`](deploy_to_blob.sh:1)) with Gitleaks integration.
- Makefile shortcuts for local development and build tasks.
- Multi-language support via Hugo’s i18n.
- Customizable portfolio sections and contact forms.

## Rationale

Using Azure services and Terraform ensures:

- Reliable, scalable static hosting.
- Infrastructure-as-code for repeatable environments.
- Automated secret scanning and secure deployments.
- Simplified maintenance and version control.

## Quick Start

### Local Development

```bash
# Start Hugo server (with drafts)
make demo

# Build production site
make build

# Preview production build
hugo server -D --source=exampleSite
```

### Repository Setup

```bash
git submodule add https://github.com/yourusername/hugo-coder.git themes/hugo-coder
```

Configure `hugo.toml` in your site root:

```toml
baseURL = "https://<your-domain>/"
languageCode = "en-us"
title = "My Portfolio"
theme = "hugo-coder"
```

Customize content under `content/` and layouts as needed.

## CI/CD with Azure & Terraform

1. Install [Terraform](https://www.terraform.io/) and the [Azure CLI](https://docs.microsoft.com/cli/azure/).
2. Initialize and apply Terraform:

   ```bash
   terraform init
   terraform apply -auto-approve
   ```

3. Export Service Principal credentials:

   ```bash
   export SP_CLIENT_ID=$(terraform output -raw sp_client_id)
   export SP_CLIENT_SECRET=$(terraform output -raw sp_client_secret)
   export TENANT_ID=$(terraform output -raw tenant_id)
   ```

4. Run deployment:

   ```bash
   ./deploy_to_blob.sh
   ```

Integrate these steps in your CI pipeline (e.g., GitHub Actions) for automated deployments.

## License

This theme is licensed under the [MIT license](LICENSE.md).

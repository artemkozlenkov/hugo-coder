+++
title = "Building AI & LLM Infrastructure as Code for Chat Applications"
date = "2025-06-12"
author = "Artem Kozlenkov"
slug = "ai-llm-infrastructure"
+++

# Building AI & LLM Infrastructure as Code for Chat Applications

The rapid advancement of Large Language Models (LLMs) and AI-powered chat applications demands robust, scalable, and secure infrastructure. This blog post presents an architectural overview and practical implementation of AI & LLM infrastructure using Infrastructure as Code (IaC) principles, focusing on Azure cloud services. We will explore how to build a modern AI infrastructure leveraging Azure App Services for containerized workloads, PostgreSQL, Redis caching, Azure Foundry, and Terraform automation.

---

## Architectural Overview

At the core of AI and LLM applications lies a set of interconnected components that enable model deployment, data persistence, caching, orchestration, and observability. The architecture below outlines a typical setup for hosting a Chat LLM application with scalable backend services and AI model lifecycle management.

- **Azure App Service (Containers):** Hosts the chat application backend as containerized microservices.
- **PostgreSQL:** Stores conversation data, user profiles, and application state.
- **Azure Redis Cache:** Provides low-latency caching for session data and rate limiting.
- **Azure Foundry:** Manages AI model lifecycle including deployment, rollbacks, and upgrades.
- **Azure Machine Learning Workspace:** Enables training, monitoring, and experimentation of models.
- **Azure Key Vault:** Securely stores credentials, keys, and secrets.
- **Azure Monitor & Log Analytics:** Provides observability across all components.

---

## Terraform Infrastructure as Code

Using Terraform, we can automate the provisioning and configuration of this infrastructure, ensuring repeatability, version control, and compliance.

### 1. Azure Resource Group and Networking

```hcl
resource "azurerm_resource_group" "ai_llm_rg" {
  name     = "rg-ai-llm"
  location = var.location
}

resource "azurerm_virtual_network" "ai_llm_vnet" {
  name                = "vnet-ai-llm"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ai_llm_rg.location
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.ai_llm_rg.name
  virtual_network_name = azurerm_virtual_network.ai_llm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "foundry_subnet" {
  name                 = "subnet-foundry"
  resource_group_name  = azurerm_resource_group.ai_llm_rg.name
  virtual_network_name = azurerm_virtual_network.ai_llm_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
```

*Explanation:*  
We start by defining a resource group and virtual network with subnets dedicated for application services and Azure Foundry. This segmentation ensures secure network boundaries and simplifies VNET peering and private endpoint configurations.

---

### 2. Azure App Service Plan and Containerized Web App

```hcl
resource "azurerm_app_service_plan" "ai_llm_plan" {
  name                = "asp-ai-llm"
  location            = azurerm_resource_group.ai_llm_rg.location
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "ai_llm_app" {
  name                = "app-ai-llm"
  location            = azurerm_resource_group.ai_llm_rg.location
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  app_service_plan_id = azurerm_app_service_plan.ai_llm_plan.id

  site_config {
    linux_fx_version = "DOCKER|myregistry.azurecr.io/ai-llm-backend:latest"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "REDIS_CACHE_HOST"                    = azurerm_redis_cache.ai_llm_redis.hostname
    "POSTGRESQL_CONNECTION_STRING"       = azurerm_postgresql_flexible_server.ai_llm_postgres.fqdn
    "AZURE_KEY_VAULT_URI"                 = azurerm_key_vault.ai_llm_kv.vault_uri
  }
}
```

*Explanation:*  
Here we provision an App Service Plan with Linux containers to host the chat backend. The container image is pulled from a private Azure Container Registry (ACR). Environment variables include Redis and PostgreSQL connection strings and Key Vault URI for secure secrets management.

---

### 3. PostgreSQL Flexible Server

```hcl
resource "azurerm_postgresql_flexible_server" "ai_llm_postgres" {
  name                = "pg-ai-llm"
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  location            = azurerm_resource_group.ai_llm_rg.location
  version             = "13"
  sku_name            = "Standard_D2s_v3"
  storage_mb          = 5120
  administrator_login = var.pg_admin_user
  administrator_password = var.pg_admin_password

  delegated_subnet_id = azurerm_subnet.app_subnet.id
  public_network_access_enabled = false
}
```

*Explanation:*  
PostgreSQL server is provisioned in a delegated subnet with no public access to enhance security. Credentials are managed securely via Terraform variables and ideally integrated with Key Vault.

---

### 4. Azure Redis Cache

```hcl
resource "azurerm_redis_cache" "ai_llm_redis" {
  name                = "redis-ai-llm"
  location            = azurerm_resource_group.ai_llm_rg.location
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
}
```

*Explanation:*  
Redis cache provides fast, in-memory data storage for session state and caching. TLS enforcement and disabling non-SSL ports ensure secure communication.

---

### 5. Azure Foundry for AI Model Lifecycle

```hcl
resource "azurerm_machine_learning_workspace" "ai_llm_mlws" {
  name                = "mlws-ai-llm"
  location            = azurerm_resource_group.ai_llm_rg.location
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  sku_name            = "Basic"
}

resource "azurerm_foundry" "ai_llm_foundry" {
  name                = "foundry-ai-llm"
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  location            = azurerm_resource_group.ai_llm_rg.location
  workspace_id        = azurerm_machine_learning_workspace.ai_llm_mlws.id

  network_profile {
    subnet_id = azurerm_subnet.foundry_subnet.id
  }
}
```

*Explanation:*  
Azure Foundry manages the AI model lifecycle, including deployment, rollbacks, and upgrades. It is linked to an Azure Machine Learning workspace for training and experimentation. Foundry is deployed in a dedicated subnet for isolation.

---

### 6. Secure Connectivity & Monitoring

```hcl
resource "azurerm_key_vault" "ai_llm_kv" {
  name                = "kv-ai-llm"
  location            = azurerm_resource_group.ai_llm_rg.location
  resource_group_name = azurerm_resource_group.ai_llm_rg.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete"
    ]
  }
}

resource "azurerm_monitor_log_profile" "ai_llm_log_profile" {
  name = "logprofile-ai-llm"
  categories = [
    "Write",
    "Delete",
    "Action"
  ]
  retention_policy {
    enabled = true
    days    = 30
  }
}
```

*Explanation:*  
Key Vault stores secrets such as database passwords, API keys, and certificates securely with strict access policies. Azure Monitor collects logs and metrics for observability and performance monitoring.

---

## Conclusion

Building AI & LLM infrastructure as code enables scalable, secure, and manageable deployments of complex AI workloads. Leveraging Azure's managed services such as App Service, PostgreSQL, Redis, Foundry, and Machine Learning Workspaces, combined with Terraform automation, empowers teams to iterate rapidly and maintain robust AI platforms.

This approach ensures that your chat LLM applications are production-ready with built-in monitoring, secure networking, and automated lifecycle management, setting the foundation for reliable and innovative AI experiences.

---

This concludes the professional, extensive blog on AI & LLM Infrastructure as Code for Chat Applications.
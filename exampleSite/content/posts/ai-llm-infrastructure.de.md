+++
title = "Aufbau von KI- & LLM-Infrastruktur als Code für Chat-Anwendungen"
date = "2025-06-12"
author = "Artem Kozlenkov"
slug = "ai-llm-infrastructure"
+++

# Aufbau von KI- & LLM-Infrastruktur als Code für Chat-Anwendungen

Der rasante Fortschritt von Large Language Models (LLMs) und KI-gestützten Chat-Anwendungen erfordert eine robuste, skalierbare und sichere Infrastruktur. Dieser Blogbeitrag präsentiert einen Architekturüberblick und eine praktische Umsetzung der KI- & LLM-Infrastruktur unter Verwendung von Infrastructure as Code (IaC)-Prinzipien mit Fokus auf Azure-Cloud-Dienste. Wir werden erkunden, wie man eine moderne KI-Infrastruktur aufbaut, die Azure App Services für containerisierte Workloads, PostgreSQL, Redis-Caching, Azure Foundry und Terraform-Automatisierung nutzt.

---

## Architekturüberblick

Im Kern von KI- und LLM-Anwendungen steht eine Reihe miteinander verbundener Komponenten, die die Modellausführung, Datenpersistenz, Caching, Orchestrierung und Beobachtbarkeit ermöglichen. Die folgende Architektur skizziert eine typische Einrichtung für das Hosting einer Chat-LLM-Anwendung mit skalierbaren Backend-Diensten und Management des Lebenszyklus von KI-Modellen.

- **Azure App Service (Container):** Hostet das Chat-Backend als containerisierte Microservices.
- **PostgreSQL:** Speichert Konversationsdaten, Benutzerprofile und Anwendungszustand.
- **Azure Redis Cache:** Bietet latenzarmes Caching für Sitzungsdaten und Ratenbegrenzungen.
- **Azure Foundry:** Verwaltert den Lebenszyklus von KI-Modellen, einschließlich Bereitstellung, Rollbacks und Upgrades.
- **Azure Machine Learning Workspace:** Ermöglicht Training, Überwachung und Experimentieren mit Modellen.
- **Azure Key Vault:** Speichert sicher Zugangsdaten, Schlüssel und Geheimnisse.
- **Azure Monitor & Log Analytics:** Bietet Beobachtbarkeit über alle Komponenten hinweg.

---

## Terraform Infrastructure as Code

Mit Terraform können wir die Bereitstellung und Konfiguration dieser Infrastruktur automatisieren, um Wiederholbarkeit, Versionskontrolle und Compliance sicherzustellen.

### 1. Azure Resource Group und Netzwerk

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

*Erklärung:*  
Wir beginnen mit der Definition einer Resource Group und eines virtuellen Netzwerks mit Subnetzen, die für Anwendungsdienste und Azure Foundry reserviert sind. Diese Segmentierung stellt sichere Netzgrenzen sicher und vereinfacht VNET-Peering und Private Endpoint-Konfigurationen.

---

### 2. Azure App Service Plan und containerisierte Web-App

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

*Erklärung:*  
Hier provisionieren wir einen App Service Plan mit Linux-Containern, um das Chat-Backend zu hosten. Das Container-Image wird aus einem privaten Azure Container Registry (ACR) gezogen. Umgebungsvariablen enthalten Redis- und PostgreSQL-Verbindungsstrings sowie die Key Vault URI für sichere Geheimnisverwaltung.

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

*Erklärung:*  
Der PostgreSQL-Server wird in einem delegierten Subnetz mit deaktiviertem öffentlichem Zugriff bereitgestellt, um die Sicherheit zu erhöhen. Zugangsdaten werden sicher über Terraform-Variablen verwaltet und idealerweise mit Key Vault integriert.

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

*Erklärung:*  
Redis Cache bietet schnellen, im Speicher befindlichen Datenspeicher für Sitzungsstatus und Caching. Die Durchsetzung von TLS und das Deaktivieren von Nicht-SSL-Ports gewährleisten eine sichere Kommunikation.

---

### 5. Azure Foundry für den KI-Modell-Lebenszyklus

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

*Erklärung:*  
Azure Foundry verwaltet den Lebenszyklus von KI-Modellen, einschließlich Bereitstellung, Rollbacks und Upgrades. Es ist mit einem Azure Machine Learning Workspace für Training und Experimente verbunden. Foundry wird in einem dedizierten Subnetz für Isolation bereitgestellt.

---

### 6. Sichere Konnektivität & Monitoring

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

*Erklärung:*  
Key Vault speichert Geheimnisse wie Datenbankpasswörter, API-Schlüssel und Zertifikate sicher mit strengen Zugriffskontrollen. Azure Monitor sammelt Logs und Metriken für Beobachtbarkeit und Leistungsüberwachung.

---

## Fazit

Der Aufbau von KI- & LLM-Infrastruktur als Code ermöglicht skalierbare, sichere und verwaltbare Bereitstellungen komplexer KI-Workloads. Die Nutzung von Azures verwalteten Diensten wie App Service, PostgreSQL, Redis, Foundry und Machine Learning Workspaces in Kombination mit Terraform-Automatisierung befähigt Teams, schnell zu iterieren und robuste KI-Plattformen zu pflegen.

Dieser Ansatz stellt sicher, dass Ihre Chat-LLM-Anwendungen produktionsbereit sind, mit integriertem Monitoring, sicherem Networking und automatisiertem Lebenszyklusmanagement, und legt die Grundlage für zuverlässige und innovative KI-Erlebnisse.

---

Dies beendet den professionellen, ausführlichen Blogbeitrag über KI- & LLM-Infrastruktur als Code für Chat-Anwendungen.
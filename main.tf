terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Variables for resource group and storage account
variable "resource_group_name" {
  type    = string
  default = "hugo-coder-rg"
}

variable "storage_account_name" {
  type    = string
  default = "hugocoderstorage"
}

# Get the storage account resource
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Get resource group resource
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Get current tenant ID
data "azurerm_client_config" "current" {}

# Create Azure AD application
resource "azuread_application" "sp_app" {
  display_name = "hugo-coder-sp"
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API
    resource_access {
      id   = "5778995a-e1bf-45b8-affa-663a9f3f4d04" # Directory.Read.All
      type = "Role"
    }
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }
  }
}

# Create Service Principal for the application
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.sp_app.application_id
}

# Create a client secret for the service principal
resource "azuread_application_password" "sp_password" {
  application_object_id = azuread_application.sp_app.object_id
  display_name         = "hugo-coder-sp-password"
  end_date_relative    = "8760h" # 1 year

  depends_on = [azuread_service_principal.sp]
}

# Assign "Storage Account Contributor" role to the SP on the storage account scope
resource "azurerm_role_assignment" "sp_role_assignment" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}

# Assign "Reader" role to the SP on the resource group scope
resource "azurerm_role_assignment" "sp_reader_rg" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.sp.object_id
}

# Output SPN credentials for use in deploy_to_blob.sh
output "sp_client_id" {
  value = azuread_application.sp_app.application_id
}

output "sp_client_secret" {
  value     = azuread_application_password.sp_password.value
  sensitive = true
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
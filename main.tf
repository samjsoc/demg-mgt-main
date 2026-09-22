module "resource_group" {
  count    = var.resource_group_create ? 1 : 0
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  location = var.location
  name     = local.resource_names.resource_group_name
  tags     = var.tags
}

# Flexible Server names are exposed on a public DNS suffix and must be globally unique across Azure.
resource "random_string" "postgresql_flexible_server_unique_name" {
  length  = 4
  special = false
  upper   = false
}

module "postgresql_flexible_server" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.2.3"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = local.resource_names.postgresql_server_name

  server_version = var.postgresql_server_version
  sku_name       = var.postgresql_sku_name
  storage_mb     = var.postgresql_storage_mb
  # Burstable (B_ prefix) SKUs don't support high availability; the module defaults to ZoneRedundant otherwise.
  high_availability = null

  public_network_access_enabled = true
  firewall_rules = {
    allow_azure_services = {
      name = "AllowAllAzureServicesAndResourcesWithinAzureIps"
      # Both start/end set to 0.0.0.0 is Azure's special sentinel for "allow Azure services", not "allow the internet".
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }

  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
  ad_administrator = {
    deployment_identity = {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = data.azurerm_client_config.current.object_id
      principal_name = var.postgresql_ad_admin_principal_name
      principal_type = var.postgresql_ad_admin_principal_type
    }
  }

  databases = {
    example = {
      name = "example"
    }
  }

  tags = var.tags
}

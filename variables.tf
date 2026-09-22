variable "resource_group_name" {
  type    = string
  default = null
}

variable "resource_group_create" {
  type    = bool
  default = false
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created. Must be in the short form (e.g. 'uksouth')"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.location))
    error_message = "The location must only contain lowercase letters, numbers, and hyphens"
  }
  validation {
    condition     = length(var.location) <= 20
    error_message = "The location must be 20 characters or less"
  }
}

variable "resource_name_workload" {
  type        = string
  description = "The name segment for the workload"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_workload))
    error_message = "The name segment for the workload must only contain lowercase letters and numbers"
  }
  validation {
    condition     = length(var.resource_name_workload) <= 4
    error_message = "The name segment for the workload must be 4 characters or less"
  }
}

variable "resource_name_environment" {
  type        = string
  description = "The name segment for the environment"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_environment))
    error_message = "The name segment for the environment must only contain lowercase letters and numbers"
  }
  validation {
    condition     = length(var.resource_name_environment) <= 4
    error_message = "The name segment for the environment must be 4 characters or less"
  }
}

variable "resource_name_sequence_start" {
  type        = number
  description = "The number to use for the resource names"
  default     = 1
  validation {
    condition     = var.resource_name_sequence_start >= 1 && var.resource_name_sequence_start <= 999
    error_message = "The number must be between 1 and 999"
  }
}

variable "resource_name_templates" {
  type        = map(string)
  description = "A map of resource names to use"
  default = {
    resource_group_name    = "rg-$${workload}-$${environment}-$${location}-$${sequence}"
    postgresql_server_name = "psql-$${workload}-$${environment}-$${location}-$${sequence}-$${uniqueness}"
  }
}

variable "postgresql_server_version" {
  type        = string
  description = "The version of PostgreSQL Flexible Server to use"
  default     = "16"
}

variable "postgresql_sku_name" {
  type        = string
  description = "The SKU Name for the PostgreSQL Flexible Server, e.g. 'B_Standard_B1ms', 'GP_Standard_D2s_v3'"
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  type        = number
  description = "The max storage allowed for the PostgreSQL Flexible Server, in MB"
  default     = 32768
}

variable "postgresql_ad_admin_principal_name" {
  type        = string
  description = "The display name of the Microsoft Entra principal to set as the PostgreSQL Flexible Server AD administrator. Defaults to the identity running Terraform."
  default     = "terraform-deployment-identity"
}

variable "postgresql_ad_admin_principal_type" {
  type        = string
  description = "The type of the Microsoft Entra principal running Terraform. Use 'ServicePrincipal' when applied via the generated pipeline's managed identity, or 'User' when applying locally with 'az login'."
  default     = "ServicePrincipal"
  validation {
    condition     = contains(["Group", "ServicePrincipal", "User"], var.postgresql_ad_admin_principal_type)
    error_message = "postgresql_ad_admin_principal_type must be one of 'Group', 'ServicePrincipal' or 'User'."
  }
}

variable "tags" {
  type = map(string)
}

# ==================================================
# Provider info:
# ==================================================
variable "deployment" {
  type = object({
    client_id           = string
    client_secret       = string
    client_obj_id       = string
    subscription_id     = string
    tenant_id           = string
  })
}

variable "artifacts" {
  type = object({
    subscription    = string
    resource_group  = string
    storage_account = string
    container_name  = string
  })
}

variable "function_version" { }
variable "env_name" { }


variable "common_vars" {
  type = object({
    location = string
    resource_group_name = string
    app_service_plan_id = string
    appinsights_id = string
    keyvault_id = string
  }) # endof type
} # endof functions

variable "function_vnet" {
  type = object({
    vnet_id = string
    subnet_name = string
    default_action = string
    ip_rules = list(string)
    virtual_network_subnet_ids = list(string)
  })
}

variable "functionapp" {
  type = object({
    fn_name = string
    full_name = string
    functions = list(string)

    storage_account = object({
      name = string
      tier = string
      replication_type = string
    })

    keyvault = object({
      cert_permissions = list(string)
      key_permissions = list(string)
      secret_permissions = list(string)
    }) # endof keyvault

    eventgrid_topics = list(string)

    settings = map(any)
  }) # endof type
} # endof functions

# ==================================================
# hashicorp Variables:
# ==================================================
variable "hashicorp" {
  type = object({
    vault            = object({
      address = string
      token = string
    })
    consul            = object({
      address = string
      token = string
      datacenter = string
    })
    key_path           = object({
      base = string
      version = string
    })
  })
}


# ==================================================
# Other Variables - Tags:
# ==================================================
variable "tags" {
  type        = map
  description = "Collection of the tags referenced by the Azure deployment"
  default = {
    source      = "terraform"
    environment = "dev"
    costCenter  = "OpenBlue Twin"
  }
}




terraform {
  required_version = ">= 0.13"
  
}



# ==================================================
# Data Resources
# ==================================================


# ==================================================
# Locals
# ==================================================
locals{
  time_delay_in_secs        = "60s"

  file_version_name = format("%s-%s.zip", var.functionapp.full_name, var.function_version) 
}


#+=======================================================================================
# Storage Account
# azurerm_storage_account.fn_sa
resource "azurerm_storage_account" "fn_sa" {
  name                          = var.functionapp.storage_account.name
  resource_group_name           = var.common_vars.resource_group_name
  location                      = var.common_vars.location
  account_tier                  = var.functionapp.storage_account.tier
  account_replication_type      = var.functionapp.storage_account.replication_type

   network_rules {
     default_action             = var.function_vnet.default_action
     ip_rules                   = var.function_vnet.ip_rules
     virtual_network_subnet_ids = var.function_vnet.virtual_network_subnet_ids
   }
  tags                          = var.tags

  depends_on                    = [] 
}

#+=======================================================================================
# azurerm_function_app.functionapp
resource "azurerm_function_app" "fnapp" {
  name                       = var.functionapp.fn_name
  location                   = var.common_vars.location
  resource_group_name        = var.common_vars.resource_group_name
  version                    = "3"
  app_service_plan_id        = var.common_vars.app_service_plan_id
  storage_account_name       = azurerm_storage_account.fn_sa.name
  storage_account_access_key = azurerm_storage_account.fn_sa.primary_access_key
  tags                       = var.tags

  identity {
    type = "SystemAssigned"
  }
 
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME        = "dotnet"
    FUNCTIONS_EXTENSION_VERSION     = "3"
    WEBSITE_NODE_DEFAULT_VERSION    = "~10"
    APPINSIGHTS_INSTRUMENTATIONKEY  = var.common_vars.appinsights_id
    VaultServiceName                = var.functionapp.full_name
    VaultAddress                    = var.hashicorp.vault.address
    VaultToken                      = var.hashicorp.vault.token
    ConsulAddress                   = var.hashicorp.consul.address
    ConsulToken                     = var.hashicorp.consul.token
    SCM_DO_BUILD_DURING_DEPLOYMENT  = false
  }
  
  depends_on          = [
      azurerm_storage_account.fn_sa
    ] 
}

#+=======================================================================================
# ACL to Grant Identity access to  KeyVault
resource "azurerm_key_vault_access_policy" "fnapp" {
  key_vault_id  = var.common_vars.keyvault_id
  tenant_id     = var.deployment.tenant_id
  object_id     = azurerm_function_app.fnapp.identity[0].principal_id

  certificate_permissions = var.functionapp.keyvault.cert_permissions
  key_permissions         = var.functionapp.keyvault.key_permissions
  secret_permissions      = var.functionapp.keyvault.secret_permissions
  
  depends_on  = [ 
    azurerm_function_app.fnapp
  ]
}

#+=======================================================================================
# Download dataflowapi function
resource "null_resource" "download" {
  triggers = {
    version = local.file_version_name
  }
  provisioner "local-exec" {
    command = "az storage blob download --file ./${local.file_version_name} --name ${local.file_version_name} --subscription ${var.artifacts.subscription} --container-name ${var.artifacts.container_name} --account-name ${var.artifacts.storage_account}"
  }
 
  depends_on = [
    azurerm_function_app.fnapp,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}

#+=======================================================================================
# Wait x after function creation
resource "time_sleep" "wait_x_seconds_after_creation" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    azurerm_function_app.fnapp,
  ]  
}

#+=======================================================================================
# Deploy dataflowapi function
resource "null_resource" "deploy" {
  triggers = {
    version = local.file_version_name
  }
  provisioner "local-exec" {
    command = "az functionapp deployment source config-zip -g ${var.common_vars.resource_group_name} -n ${var.functionapp.fn_name} --src ./${local.file_version_name}"
  }
 
  depends_on = [
    time_sleep.wait_x_seconds_after_creation,
    # azurerm_function_app.fnapp,
    # null_resource.download,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}

#+=======================================================================================
# Wait x after deploy
resource "time_sleep" "wait_x_seconds_after_deploy" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    null_resource.deploy,
    # time_sleep.wait_x_seconds_after_creation,
    # azurerm_function_app.fnapp,
    # null_resource.download,
    # null_resource.az_login,
    # null_resource.az_subscription_set
  ]
}

#+=======================================================================================
# Register vnet with function
resource "null_resource" "vnet_config" {
  provisioner "local-exec" {
    command = "az functionapp vnet-integration add -g ${var.common_vars.resource_group_name} -n  ${var.functionapp.fn_name} --vnet ${var.function_vnet.vnet_id} --subnet ${var.function_vnet.subnet_name}"
  }
 
  depends_on = [
    time_sleep.wait_x_seconds_after_deploy,
    # null_resource.deploy,
    # time_sleep.wait_x_seconds_after_creation,
    # azurerm_function_app.fnapp,
    # null_resource.download,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}

#+=======================================================================================
# Wait x after deploy
resource "time_sleep" "wait_x_seconds_after_vnet_config" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    null_resource.vnet_config,
    # time_sleep.wait_x_seconds_after_deploy,
    # null_resource.deploy,
    # time_sleep.wait_x_seconds_after_creation,
    # azurerm_function_app.fnapp,
    # null_resource.download,
    # null_resource.az_login,
    # null_resource.az_subscription_set
  ]
}


#+=======================================================================================
# Get function keys
#---------------------------------------------------------------------------------
# data.azurerm_function_app_host_keys.keyextraction.default_function_key
# data.azurerm_function_app_host_keys.keyextraction.master_key 
#---------------------------------------------------------------------------------
data "azurerm_function_app_host_keys" "keyextraction" {
  name                = var.functionapp.fn_name
  resource_group_name = var.common_vars.resource_group_name

  depends_on = [
    time_sleep.wait_x_seconds_after_vnet_config,
    # null_resource.vnet_config,
    # time_sleep.wait_x_seconds_after_deploy,
    # null_resource.deploy,
    # time_sleep.wait_x_seconds_after_creation,
    # azurerm_function_app.fnapp,
    # null_resource.download,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}

#+=======================================================================================
# Login to Azure
resource "null_resource" "az_login" {
  provisioner "local-exec" {
    command = "az login --service-principal -u ${var.deployment.client_id} -p ${var.deployment.client_secret} --tenant ${var.deployment.tenant_id}"
  }

  depends_on = []
}

#+=======================================================================================
# Set Azure Subscription
resource "null_resource" "az_subscription_set" {
  provisioner "local-exec" {
    command = " az account set --subscription ${var.deployment.subscription_id}"
  }

  depends_on = [null_resource.az_login]
}

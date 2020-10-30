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
 
  # app_settings = {
  #   FUNCTIONS_WORKER_RUNTIME        = "dotnet"
  #   FUNCTIONS_EXTENSION_VERSION     = "3"
  #   WEBSITE_NODE_DEFAULT_VERSION    = "~10"
  #   APPINSIGHTS_INSTRUMENTATIONKEY  = var.common_vars.appinsights_id
  #   serviceName                     = var.functionapp.full_name
  #   vaultAddress                    = var.hashicorp.vault.address
  #   vaultToken                      = var.hashicorp.vault.token
  #   ConsulAddress                   = var.hashicorp.consul.address
  #   ConsulToken                     = var.hashicorp.consul.token
  #   SCM_DO_BUILD_DURING_DEPLOYMENT  = false
  #   DT_TENANT                       = var.dynatrace.DT_TENANT
  #   DT_API_TOKEN                    = var.dynatrace.DT_API_TOKEN
  #   DT_API_URL                      = var.dynatrace.DT_API_URL
  # }

  app_settings = var.app_settings

  site_config {
    always_on = true
  }
  
  depends_on          = [
      azurerm_storage_account.fn_sa
    ] 
}
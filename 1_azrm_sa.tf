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
#+=======================================================================================
# Wait x after deploy
resource "time_sleep" "wait_x_seconds_after_vnet_config" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    null_resource.vnet_config,
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
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}
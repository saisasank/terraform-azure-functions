#+=======================================================================================
# Wait x after deploy
resource "time_sleep" "wait_x_seconds_after_deploy" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    null_resource.deploy,
    azurerm_function_app.fnapp,
    time_sleep.wait_x_seconds_after_creation,
    null_resource.az_login,
    null_resource.az_subscription_set,
    null_resource.download,
    null_resource.deploy
  ]
}

#+=======================================================================================
# Register vnet with function
resource "null_resource" "vnet_config" {
  count         = var.toggle_configure_vnet_connection ? 1 : 0

  provisioner "local-exec" {
    command = "az functionapp vnet-integration add -g ${var.common_vars.resource_group_name} -n  ${var.functionapp.fn_name} --vnet ${var.function_vnet.vnet_id} --subnet ${var.function_vnet.subnet_name}"
  }
 
  depends_on = [
    azurerm_function_app.fnapp,
    time_sleep.wait_x_seconds_after_creation,
    null_resource.az_login,
    null_resource.az_subscription_set,
    null_resource.download,
    null_resource.deploy,
    time_sleep.wait_x_seconds_after_deploy
  ]
}

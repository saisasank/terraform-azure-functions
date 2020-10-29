#+=======================================================================================
# Wait x after function creation
resource "time_sleep" "wait_x_seconds_after_creation" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    null_resource.az_login,
    null_resource.az_subscription_set,
    azurerm_function_app.fnapp,
    null_resource.download
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
    null_resource.az_login,
    null_resource.az_subscription_set,
    azurerm_function_app.fnapp,
    null_resource.download,
    time_sleep.wait_x_seconds_after_creation
  ]
}

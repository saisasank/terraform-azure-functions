#+=======================================================================================
# Wait x after function creation
resource "time_sleep" "wait_x_seconds_after_creation" {
  create_duration = local.time_delay_in_secs

  depends_on = [
    azurerm_function_app.fnapp,
    null_resource.download,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]  
}

#+=======================================================================================
# Deploy dataflowapi function
resource "null_resource" "deploy" {
  triggers = {
    version = local.file_version_name
  }
  provisioner "local-exec" {
    command = "az functionapp deployment source config-zip -g ${var.common_vars.resource_group_name} -n ${var.functionapp.fn_name} --src ./${local.file_version_name} --auth-mode login"
  }
 
  depends_on = [
    azurerm_function_app.fnapp,
    time_sleep.wait_x_seconds_after_creation,
    null_resource.download,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}

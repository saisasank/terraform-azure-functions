
#+=======================================================================================
# Remove AzureWebJobsDashboard
resource "null_resource" "RemoveWebJobDash" {
  triggers = {
    version = local.file_version_name
  }

  provisioner "local-exec" {
    command = "az functionapp appsettings delete -g ${var.common_vars.resource_group_name} -n  ${var.functionapp.fn_name} --setting-names AzureWebJobsDashboard"
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

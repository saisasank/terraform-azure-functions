#+=======================================================================================
# Download dataflowapi function
resource "null_resource" "download" {
  triggers = {
    version = local.file_version_name
  }
  provisioner "local-exec" {
    command = "az storage blob download --file ./${local.file_version_name} --name ${local.file_version_name} --subscription ${var.artifacts.subscription} --container-name ${var.artifacts.container_name} --account-name ${var.artifacts.storage_account} --account-key UqV/oMMBlPaheBi3eDJeEEx14R/EZ8jGuVULCeRqMvbxrVAqGoLZ/OKe03rKBAwjYWk28Q7BHXfA/zQLd5g0mg=="
  }
 
  depends_on = [
    azurerm_function_app.fnapp,
    null_resource.az_login,
    null_resource.az_subscription_set
  ]
}

#+=======================================================================================
# Login to Azure
resource "null_resource" "az_login" {
  triggers = {
    version = local.file_version_name
  }
  
  provisioner "local-exec" {
    command = "az login --service-principal -u ${var.deployment.client_id} -p ${var.deployment.client_secret} --tenant ${var.deployment.tenant_id}"
  }

  depends_on = []
}

#+=======================================================================================
# Set Azure Subscription
resource "null_resource" "az_subscription_set" {
  triggers = {
    version = local.file_version_name
  }
  
  provisioner "local-exec" {
    command = "az account set --subscription ${var.deployment.subscription_id}"
  }

  depends_on = [null_resource.az_login]
}

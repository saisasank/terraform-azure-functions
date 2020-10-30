#+=======================================================================================
#+=======================================================================================
#+=======================================================================================
# Vault Infra Settings
#+=======================================================================================
resource "vault_generic_secret" "func_id" {
  count   = var.toggle_configure_infra_to_vault ? 1 : 0
  
  path = "${local.vault_path_infra}/${var.functionapp.full_name}/function_id"
  data_json = <<EOT
{"value": "${azurerm_function_app.fnapp.id}"}
EOT
depends_on = [azurerm_function_app.fnapp, null_resource.deploy]
}

resource "vault_generic_secret" "func_default_hostname" {
  count   = var.toggle_configure_infra_to_vault ? 1 : 0

  path = "${local.vault_path_infra}/${var.functionapp.full_name}/default_hostname"
  data_json = <<EOT
{"value": "${azurerm_function_app.fnapp.default_hostname}"}
EOT
  depends_on = [azurerm_function_app.fnapp, null_resource.deploy]
}

resource "vault_generic_secret" "fn_functionkeys" {
  count   = var.toggle_configure_infra_to_vault ? 1 : 0
  
  path = "${local.vault_path_infra}/${var.functionapp.full_name}/function_keys"
  data_json = <<EOT
{"value": "${data.azurerm_function_app_host_keys.keyextraction.default_function_key}"}
EOT
  depends_on = [
    azurerm_function_app.fnapp, 
    null_resource.deploy,
    data.azurerm_function_app_host_keys.keyextraction
  ]
}

resource "vault_generic_secret" "fn_masterkeys" {
  count   = var.toggle_configure_infra_to_vault ? 1 : 0
  
  path = "${local.vault_path_infra}/${var.functionapp.full_name}/master_keys"
  data_json = <<EOT
{"value": "${data.azurerm_function_app_host_keys.keyextraction.master_key }"}
EOT
  depends_on = [
    azurerm_function_app.fnapp, 
    null_resource.deploy,
    data.azurerm_function_app_host_keys.keyextraction
  ]
}
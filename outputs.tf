output "function_id" {
  value = azurerm_function_app.fnapp.id
}

output "default_hostname" {
  value = azurerm_function_app.fnapp.default_hostname
}

output "function_keys" {
  value = data.azurerm_function_app_host_keys.keyextraction.default_function_key
}

output "master_keys" {
  value =data.azurerm_function_app_host_keys.keyextraction.master_key
}

output "function_principal_id" {
    value = azurerm_function_app.fnapp.identity[0].principal_id
}

output "function_sa_primary_connection_string" {
  value = azurerm_storage_account.fnapp.primary_connection_string
}

output "function_sa_secondary_connection_string" {
  value = azurerm_storage_account.fnapp.secondary_connection_string
}

output "function_sa_id" {
  value = azurerm_storage_account.fnapp.id
}
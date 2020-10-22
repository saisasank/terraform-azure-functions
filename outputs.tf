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
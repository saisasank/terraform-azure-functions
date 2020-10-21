#+=======================================================================================
# ACL to Grant Identity access to  KeyVault
resource "azurerm_key_vault_access_policy" "fnapp" {
  key_vault_id  = var.common_vars.keyvault_id
  tenant_id     = var.deployment.tenant_id
  object_id     = azurerm_function_app.fnapp.identity[0].principal_id

  certificate_permissions = var.functionapp.keyvault.cert_permissions
  key_permissions         = var.functionapp.keyvault.key_permissions
  secret_permissions      = var.functionapp.keyvault.secret_permissions
  
  depends_on  = [ 
    azurerm_function_app.fnapp
  ]
}
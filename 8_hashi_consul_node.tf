#============================================
# Consul Service Registration
resource "consul_node" "fn_node" {
  name    = var.functionapp.fn_name
  address = azurerm_function_app.fnapp.default_hostname

  depends_on = [ azurerm_function_app.fnapp ]
}
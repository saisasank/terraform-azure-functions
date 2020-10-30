#============================================
# Consul Service Registration
resource "consul_node" "fn_node" {
  count   = var.toggle_configure_consul_node ? 1 : 0
  
  name    = var.functionapp.fn_name
  address = azurerm_function_app.fnapp.default_hostname

  depends_on = [ azurerm_function_app.fnapp ]
}
#============================================
# Consul Service Registration
resource "consul_service" "fn_svc" {
  count   = var.toggle_configure_consul_service ? 1 : 0

  name    = var.functionapp.fn_name
  node    = consul_node.fn_node[count.index].name
  port    = 443
  tags    = [var.env_name, var.functionapp.fn_name]

  check {
    check_id                          = "service:${var.functionapp.fn_name}"
    name                              = "${var.functionapp.fn_name} health check"
    status                            = "passing"
    http                              = "https://${azurerm_function_app.fnapp.default_hostname}/api/status"
    tls_skip_verify                   = false
    method                            = "GET"
    interval                          = "5s"
    timeout                           = "1s"
    deregister_critical_service_after = "30s"
  }
  depends_on = [consul_node.fn_node]
}

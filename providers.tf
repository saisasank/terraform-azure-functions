# # ==================================================
# # Providers
# # ==================================================
# provider "azurerm" {
#   version = "~> 2.32.0" #"~> 1.39"
#   features {}
#   client_id       = var.deployment.client_id
#   subscription_id = var.deployment.subscription_id
#   tenant_id       = var.deployment.tenant_id
#   client_secret   = var.deployment.client_secret
# }

# provider "vault" {
#     version = "2.15.0"
#     #source = "hashicorp/vault"
#     address         = var.hashicorp.vault.address
#     token           = var.hashicorp.vault.token
#     skip_tls_verify = "true"
# }

# provider "consul" {
#   version = "2.10.0"
#   address           = var.hashicorp.consul.address
#   datacenter        = var.hashicorp.consul.datacenter
#   token             = var.hashicorp.consul.token
# }

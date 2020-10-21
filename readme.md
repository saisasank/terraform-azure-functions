
# terraform-azure-functions
The purpose of this repo is to provide a base terraform modules for deploying azure functions. This modules assumes the following resources areaalready existing and are passed into the module:

- Resource Group
- Azure App Service/Plan
- Network

## Example Invocation:
Calling function:

```t
module "function_app" {
    #source = "./function_app"
    source = "github.com/ploegert/terraform-azure-functions"

    deployment                   = local.workspace["deployment"]
    artifacts                    = local.workspace["artifacts"]
    #function_version             = local.workspace["function_version"]
    function_version             = var.function_version
    functionapp                  = local.workspace["dataflow"]
    hashicorp                    = local.workspace["hashicorp"]
    tags                         = local.workspace["tags"]

    common_vars = {
        location                 = local.common.location
        resource_group_name      = local.obc.resource_group
        app_service_plan_id      = module.obc_shared.app_svc_plan_id
        appinsights_id           = module.obc_shared.ai_instrumentation_key
        keyvault_id              = module.obc_shared.key_vault_id
    }
    function_vnet = {
        vnet_id              = module.obc_shared.vnet_id
        subnet_name          = module.obc_shared.vnet_func_subnet_name
        default_action       = "Deny"
        ip_rules             = [chomp(data.http.myip.body)]
        virtual_network_subnet_ids = [
            module.obc_shared.vnet_func_subnet_id,
            local.workspace["agent_subnet_id"]
        ]
    }
}
```
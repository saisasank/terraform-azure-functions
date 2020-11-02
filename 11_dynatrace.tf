#+=======================================================================================
# ARM template for Azure Function extension for Dynatrace
#+=======================================================================================
resource "azurerm_template_deployment" "dynatrace_functions_extension" {
    count               = var.toggle_configure_dynatrace ? 1 : 0
    name                = var.functionapp.fn_name
    resource_group_name = var.common_vars.resource_group_name
    template_body       = file("${path.module}/arm/function-dynatrace-extension.json")

    parameters = {
        app_svc_plan    = var.common_vars.app_service_plan_id
        app_svc         = var.functionapp.fn_name
        location        = var.common_vars.location
    }
    deployment_mode = "Incremental"
    depends_on = [ 
        azurerm_function_app.fnapp,
        time_sleep.wait_x_seconds_after_creation,
        null_resource.az_login,
        null_resource.az_subscription_set,
        null_resource.download,
        time_sleep.wait_x_seconds_after_deploy,
        time_sleep.wait_x_seconds_after_vnet_config
    ]
}
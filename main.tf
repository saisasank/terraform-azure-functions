
terraform {
  required_version = ">= 0.13"
  
}


# ==================================================
# Locals
# ==================================================
locals{
  time_delay_in_secs        = "60s"
  vault_path_infra          = "${var.hashicorp.key_path.base}/${var.env_name}/infra/${var.hashicorp.key_path.version}"
  file_version_name         = format("%s-%s.zip", var.functionapp.full_name, var.function_version) 
}

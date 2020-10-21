
terraform {
  required_version = ">= 0.13"
  
}


# ==================================================
# Locals
# ==================================================
locals{
  time_delay_in_secs        = "60s"

  file_version_name = format("%s-%s.zip", var.functionapp.full_name, var.function_version) 
}

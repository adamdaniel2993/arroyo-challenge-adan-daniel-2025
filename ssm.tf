locals {
  proyect_name = "arroyo"
}

resource "aws_ssm_parameter" "arroyo_db_password" {
  name  = "${local.proyect_name}_db_password"
  type  = "SecureString"
  value = random_password.arroyo_db_password.result
}
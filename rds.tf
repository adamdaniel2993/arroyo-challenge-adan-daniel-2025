resource "random_password" "arroyo_db_password" {
  length  = 16
  special = false
}


resource "aws_db_instance" "arroyo-rds" {
  identifier             = "${local.proyect_name}-db"
  allocated_storage      = 20
  db_name                = "ArroyoDB"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = local.proyect_name
  password               = random_password.arroyo_db_password.result
  parameter_group_name   = aws_db_parameter_group.pg_params.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.arroyo_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.arroyo-db-subnet-group.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

}

resource "aws_db_subnet_group" "arroyo-db-subnet-group" {
  name       = "${local.proyect_name}-db-subnet-group"
  subnet_ids = [module.arroyo_vpc.private_subnets[0], module.arroyo_vpc.private_subnets[1]]
}


resource "aws_db_parameter_group" "pg_params" {
  name   = "${local.proyect_name}-pg15-params"
  family = "postgres15"

  parameter {
    name  = "log_min_duration_statement"
    value = "200"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }
}

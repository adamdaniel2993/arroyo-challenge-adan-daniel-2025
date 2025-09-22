resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${local.proyect_name}/app"
  retention_in_days = 14
  tags = {
    Project = local.proyect_name
  }
}


resource "aws_ecs_task_definition" "arroyo-task-def" {
  family                   = local.proyect_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_exec_role.arn

  container_definitions = jsonencode([
    {
      name  = "${local.proyect_name}-challenge"
      image = "${aws_ecrpublic_repository.arroyo-ecr.repository_uri}:latest"
      environment = [
        { name = "DB_HOST", value = aws_db_instance.arroyo-rds.address },
        { name = "DB_NAME", value = aws_db_instance.arroyo-rds.db_name },
        { name = "DB_USER", value = local.proyect_name }
      ]
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_ssm_parameter.arroyo_db_password.arn
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -h $DB_HOST -U $DB_USER -d $DB_NAME || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "app"
        }
      }

      memory = 256
      cpu    = 256

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      essential = true
    }
  ])
}


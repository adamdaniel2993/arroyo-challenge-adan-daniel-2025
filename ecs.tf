resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.proyect_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_service" "arroyo-challenge-service" {
  name            = "${local.proyect_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.arroyo-task-def.id
  launch_type     = "EC2"
  desired_count   = 1

  network_configuration {
    subnets = [module.arroyo_vpc.private_subnets[0], module.arroyo_vpc.private_subnets[1]]

    security_groups = [
      aws_security_group.arroyo_ec2_sg.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.arroyo-tg.arn
    container_name   = "${local.proyect_name}-challenge" # Replace with your container name
    container_port   = 80
  }
}
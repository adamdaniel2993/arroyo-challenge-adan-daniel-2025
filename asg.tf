resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                = "${local.proyect_name}-asg"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = [module.arroyo_vpc.public_subnets[0], module.arroyo_vpc.public_subnets[1]] #Multi-AZ
  launch_template {
    name    = aws_launch_template.ecs_launch_template.name
    version = "$Latest"
  }
}
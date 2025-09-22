resource "aws_launch_template" "ecs_launch_template" {
  name          = "${local.proyect_name}-lt"
  image_id      = data.aws_ssm_parameter.ami.value
  key_name      = "challenge"
  instance_type = "t3.small"
  user_data     = base64encode(templatefile("${path.module}/templates/userdata-template.tmpl", { cluster_name = aws_ecs_cluster.ecs_cluster.name }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.arroyo_ec2_sg.id]
    subnet_id                   = module.arroyo_vpc.public_subnets[0]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_ec2_instance_profile.name
  }

}



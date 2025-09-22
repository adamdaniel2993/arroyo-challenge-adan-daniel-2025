resource "aws_security_group" "arroyo_ec2_sg" {
  name   = "${local.proyect_name}-ec2-sg"
  vpc_id = module.arroyo_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "${local.proyect_name}-ec2-sg"
  }
}

resource "aws_security_group_rule" "from_my_ip" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["186.6.136.3/32"]
  security_group_id        = aws_security_group.arroyo_ec2_sg.id
}

resource "aws_security_group_rule" "from_lb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.arroyo_ec2_sg.id
  source_security_group_id = aws_security_group.arroyo_lb_sg.id
}


##### RDS security groups

resource "aws_security_group" "arroyo_db_sg" {
  name   = "${local.proyect_name}-db-sg"
  vpc_id = module.arroyo_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "${local.proyect_name}-db-sg"
  }
}

resource "aws_security_group_rule" "from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.arroyo_db_sg.id
  source_security_group_id = aws_security_group.arroyo_ec2_sg.id
}



#### Load Balancer security groups

resource "aws_security_group" "arroyo_lb_sg" {
  name   = "${local.proyect_name}-lb-sg"
  vpc_id = module.arroyo_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "${local.proyect_name}-lb-sg"
  }
}
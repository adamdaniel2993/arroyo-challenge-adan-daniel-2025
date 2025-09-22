resource "aws_lb" "arroyo-lb" {
  name                       = "${local.proyect_name}-lb-tf"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.arroyo_lb_sg.id]
  subnets                    = [module.arroyo_vpc.public_subnets[0], module.arroyo_vpc.public_subnets[1]]
  enable_deletion_protection = false

}

resource "aws_lb_listener" "arroyo-lb-listener" {
  load_balancer_arn = aws_lb.arroyo-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arroyo-tg.arn
  }

}

resource "aws_lb_target_group" "arroyo-tg" {
  name        = "${local.proyect_name}-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.arroyo_vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

}
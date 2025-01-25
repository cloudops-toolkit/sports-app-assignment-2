resource "aws_lb" "main" {
  name               = "${var.project}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets           = var.public_subnet_ids
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project}-tg-${var.environment}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/healthcheck"  # Change this to match task definition
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout            = 30                   # Add these parameters
    interval           = 45                   # to match task definition
    matcher            = "200"                # Accept 200 as healthy
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
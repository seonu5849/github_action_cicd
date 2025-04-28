# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# application
resource "aws_lb" "shinemuscat_alb" {
  name               = "${ var.common.prefix }-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [for subnet in var.vpc_public_subnet_ids : subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "${ var.common.prefix }-alb"
  }
}

# #############################################################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# instance
resource "aws_lb_target_group" "shinemuscat_alb_target_group_blue" {
  name     = "${ var.common.prefix }-atg-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = 200
    protocol            = "HTTP"
  }
}

resource "aws_lb_target_group" "shinemuscat_alb_target_group_green" {
  name     = "${ var.common.prefix }-atg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = 200
    protocol            = "HTTP"
  }
}

# #############################################################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.shinemuscat_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shinemuscat_alb_target_group_blue.arn
  }

  tags = {
    name = "${var.common.prefix}_alb_listener"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# 모든 경로와 일치하는 요청을 ASG가 포함된 대상 그룹으로 보냄
resource "aws_lb_listener_rule" "terraform-lbrule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.shinemuscat_alb_target_group_blue.arn
  }
}

# #############################################################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
# resource "aws_lb_target_group_attachment" "shinemuscat_target_group_attachment" {
#   count            = length(var.app_instance_ids)
#   target_group_arn = aws_lb_target_group.shinemuscat_alb_target_group.arn
#   target_id        = var.app_instance_ids[count.index].id
#   port             = 8080
# }

# #############################################################################################
# alb security group
resource "aws_security_group" "alb_security_group" {
  name = "alb-security-group"
  description = "Allow SSH to access ALB"
  vpc_id = var.vpc_id

  tags = {
    Name = "${ var.common.prefix }-alb-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound_http" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # 모든 프로토콜 허용
}
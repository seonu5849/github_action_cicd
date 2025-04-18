
output "alb_target_group_blue" {
  value = aws_lb_target_group.shinemuscat_alb_target_group_blue
}

output "alb_target_group_green" {
  value = aws_lb_target_group.shinemuscat_alb_target_group_green
}

output "alb_listener" {
  value = aws_lb_listener.alb_listener
}

output "alb" {
  value = aws_lb.shinemuscat_alb
}
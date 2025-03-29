
output "alb_target_group" {
  value = aws_lb_target_group.shinemuscat_alb_target_group
}

output "alb_listener" {
  value = aws_lb_listener.alb_listener
}
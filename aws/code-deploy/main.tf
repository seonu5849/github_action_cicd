
resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name = "${var.common.prefix}-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "codedploy-deployment-group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.common.prefix}-deployment-group"
  service_role_arn      = var.iam_role.arn

  # 배포 유형
  deployment_style {
    deployment_type = "IN_PLACE" # 현재위치(Default), BLUE_GREEN (블루그린)
  }

  # Amazon EC2 Auto Scaling 그룹
  autoscaling_groups = [var.autoscaling-group.id]

  # 배포 설정
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # 로드 밸런서
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener.arn]
      }

      target_group {
        name = var.alb_target_group.name
      }
    }
  }
}
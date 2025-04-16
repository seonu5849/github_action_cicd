
resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name = "${var.common.prefix}-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "codedploy-deployment-group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.common.prefix}-deployment-group"
  service_role_arn      = var.iam_role.arn

  # 배포 유형의 구성 블록
  deployment_style {
    # deployment_type
    #   IN_PLACE(기본값) = 기존 인스턴스 위에서 앱을 업데이트, EC2 인스턴스를 종료하지 않고, 서비스 중인 인스턴스에 직접 배포
    #   BLUE_GREEN = 신규 인스턴스나 Auto Scaling Group을 만들어 새 환경에 배포, 롤백과 무중단 배포에 유리
    deployment_type = "IN_PLACE"

    # deployment_option
    #   WITH_TRAFFIC_CONTROL = 트래픽 전환 제어(ALB를 통한 트래직 점진 전환) - BLUE_GREEN 전용
    #   WITHOUT_TRAFFIC_CONTROL(기본값) = 트래픽 제어 없이 배포, 즉시 전환 - IN_PLACE 또는 BLUE_GREEN 모두 가능
    deployment_option = "WITHOUT_TRAFFIC_CONTROL" # 로드 밸런서 뒤에 배치 트래픽을 경로로 배치할지 여부를 나타냄 (기본값은 WITH_TRAFFIC_CONTROL)
  }

  # Amazon EC2 Auto Scaling 그룹
  autoscaling_groups = [var.autoscaling-group.name]

  # 배포 설정
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # 로드 밸런서
#   load_balancer_info {
#     target_group_pair_info {
#       prod_traffic_route {
#         listener_arns = [var.alb_listener.arn]
#       }
#
#       target_group {
#         name = var.alb_target_group.name
#       }
#     }
#   }
}
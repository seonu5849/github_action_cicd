
resource "aws_codedeploy_app" "app" {
  # compute_platform = Compute 플랫폼
  #   ECS, Lambda, Server(기본값) - Server가 EC2
  compute_platform = "Server"
  name = "${var.common.prefix}-codedeploy-app"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group
resource "aws_codedeploy_deployment_group" "codedploy-deployment-group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.common.prefix}-deployment-group"
  service_role_arn      = var.iam_role.arn

  # 배포 구성 = 기본 및 사용자 지정 배포 구성 목록에서 선택합니다. 배포 구성은 애플리케이션이 배포되는 속도와 배포 성공 또는 실패 조건을 결정하는 규칙 세트입니다.
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # 배포 유형의 구성 블록
  deployment_style {
    # deployment_option
    #   WITH_TRAFFIC_CONTROL = 트래픽 전환 제어(ALB를 통한 트래직 점진 전환) - BLUE_GREEN 전용
    #   WITHOUT_TRAFFIC_CONTROL(기본값) = 트래픽 제어 없이 배포, 즉시 전환 - IN_PLACE 또는 BLUE_GREEN 모두 가능
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"

    # deployment_type
    #   IN_PLACE(기본값) = 기존 인스턴스 위에서 앱을 업데이트, EC2 인스턴스를 종료하지 않고, 서비스 중인 인스턴스에 직접 배포
    #   BLUE_GREEN = 신규 인스턴스나 Auto Scaling Group을 만들어 새 환경에 배포, 롤백과 무중단 배포에 유리
    deployment_type = "IN_PLACE"
  }

  # Amazon EC2 Auto Scaling 그룹
  autoscaling_groups = [var.autoscaling-group.name]

  # 로드 밸런서 트래픽을 어디로 전환할지를 지정, blue-green 적용시 사용
#  load_balancer_info {
#    target_group_info {
#      name = var.alb_target_group_green.name
#    }
#  }

  # 배포 실패 시 롤백
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
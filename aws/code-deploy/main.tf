
resource "aws_codedeploy_app" "app" {
  # compute_platform = Compute 플랫폼
  #   ECS, Lambda, Server(기본값) - Server가 EC2
  compute_platform = "Server"
  name = "${var.common.prefix}-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "codedploy-deployment-group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.common.prefix}-deployment-group"
  service_role_arn      = var.iam_role.arn

  # 배포 유형의 구성 블록
  deployment_style {
    # deployment_option
    #   WITH_TRAFFIC_CONTROL = 트래픽 전환 제어(ALB를 통한 트래직 점진 전환) - BLUE_GREEN 전용
    #   WITHOUT_TRAFFIC_CONTROL(기본값) = 트래픽 제어 없이 배포, 즉시 전환 - IN_PLACE 또는 BLUE_GREEN 모두 가능
    deployment_option = "WITH_TRAFFIC_CONTROL"

    # deployment_type
    #   IN_PLACE(기본값) = 기존 인스턴스 위에서 앱을 업데이트, EC2 인스턴스를 종료하지 않고, 서비스 중인 인스턴스에 직접 배포
    #   BLUE_GREEN = 신규 인스턴스나 Auto Scaling Group을 만들어 새 환경에 배포, 롤백과 무중단 배포에 유리
    deployment_type = "BLUE_GREEN"
  }

  # Amazon EC2 Auto Scaling 그룹
  autoscaling_groups = [var.autoscaling-group.name]

  # 로드 밸런서 트래픽을 어디로 전환할지를 지정, blue-green 적용시 사용
#   load_balancer_info {
#     target_group_pair_info {
#       prod_traffic_route {
#         listener_arns = [var.alb_listener.arn]
#       }
#
#       # blue target group
#       target_group {
#         name = var.alb_target_group_blue.name
#       }
#
#       # green target group
#       target_group {
#         name = var.alb_target_group_green.name
#       }
#     }
#   }
  load_balancer_info {
    elb_info {
      name = var.alb.name
    }



    target_group_info {
      name = var.alb_target_group_blue.name
    }

    target_group_info {
      name = var.alb_target_group_green.name
    }
  }

  # Blue/Green 배포 전환 절차 및 타이밍을 제어, deployment_style.deployment_type = "BLUE_GREEN"일때만 사용 가능
  blue_green_deployment_config {
    deployment_ready_option {
      # 트래픽 전환 전 대기 시간과, 그 시간 동안 수동 승인(예: 수동 테스트)이 이루어지지 않았을 경우 행동을 정의
      # "CONTINUE_DEPLOYMENT" = 대기 시간 경과 후 자동으로 트래픽 전환 진행
      # "STOP_DEPLOYMENT" = 대기 시간 경과 시 배포 중단
      action_on_timeout    = "CONTINUE_DEPLOYMENT"

      # 트래픽 전환 전 대기 시간(분 단위). QA 테스트나 수동 승인을 위해 활용 가능
#       wait_time_in_minutes = 15
    }

    green_fleet_provisioning_option {
      # Green 환경(새롭게 배포될 대상 인프라)을 구성하는 방식 지정
      # "COPY_AUTO_SCALING_GROUP" = 기존 Auto Scaling Group을 복사하여 Green 환경 생성
      # "DISCOVER_EXISTING" = 이미 존재하는 인스턴스나 Auto Scaling Group을 탐지하여 사용
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      # 배포 성공 후 기존 Blue 인스턴스를 종료할지 결정
      # "TERMINATE" → Green으로 전환 완료되면 Blue 인스턴스 자동 종료
      # "KEEP_ALIVE" → Blue 인스턴스를 유지함
      action = "TERMINATE"

      # 종료 전 대기 시간(분 단위). 이 시간 동안 기존 인스턴스를 유지한 후 종료
      termination_wait_time_in_minutes = 5
    }
  }

  # 배포 구성 = 기본 및 사용자 지정 배포 구성 목록에서 선택합니다. 배포 구성은 애플리케이션이 배포되는 속도와 배포 성공 또는 실패 조건을 결정하는 규칙 세트입니다.
  deployment_config_name = "CodeDeployDefault.OneAtATime"
}
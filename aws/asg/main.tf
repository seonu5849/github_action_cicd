
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "autoscaling-group" {
  name               = "${var.common.prefix}-autoscaling-group"
  desired_capacity   = 2
  max_size           = 2
  min_size           = 1

  # vpc private subnet 연결
  vpc_zone_identifier = [var.vpc_private_subnet_id]

  health_check_type   = "EC2"        # ELB 로드밸런서 연결 시 서비스 상태에 따라 헬스체크 (만약 서비스가 에러를 내보낸다면 인스턴스 종료 후 재생성)
  health_check_grace_period = 300          # 초기 인스턴스 기동 후 몇 초간 상태 체크 보류

  # 인스턴스를 축소할 때 어떤 기준으로 종료할지 정의
  # OldestInstance: 가장 오래된 인스턴스 종료
  # ClosestToNextInstanceHour: 시간당 과금 기준에 맞춰 비용 최적화
  termination_policies = ["OldestInstance", "ClosestToNextInstanceHour"]

  # 로드 밸런서 대상 그룹과 연동할 경우 필요
  target_group_arns = [var.alb_target_group_blue.arn]

  # 스팟 인스턴스를 사용하는 경우, EC2에서 중단 신호를 받기 전에 대체 인스턴스를 미리 시작
  capacity_rebalance = true

  launch_template {
    id = var.launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.common.prefix}-ec2"
    propagate_at_launch = true # true인 경우, 이 태그가 Auto Scaling Group이 생성한 EC2 인스턴스에도 자동 부여됨
  }
}
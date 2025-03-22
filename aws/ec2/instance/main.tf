
# 리소스 블록으로 인프라의 구성 요소를 정의하는 곳
# 리소스 유형은 "aws_instance", 인스턴스 이름은 "shinemuscat-ec2"으로 설정된다.
# EC2 인스턴스의 ID는 aws_instance.app_server로 생성
resource "aws_instance" "shinemuscat-ec2" {
  count = var.counts

  subnet_id = var.vpc_subnet_id

  launch_template {
    id = var.launch_template_id
  }

  tags = {
    Name = "${ var.common.prefix }-${var.name}-${count.index + 1}" # 인스턴스 이름
  }
}



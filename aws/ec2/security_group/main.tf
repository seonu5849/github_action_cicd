
# ec2 접속을 위한 ssh 포트 개방
resource "aws_security_group" "ec2_security_group" {
  name = "ec2-security-group"
  description = "Allow SSH to access EC2"
  vpc_id = var.vpc_id

  tags = {
    Name = "${ var.common.prefix }-ec2-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_ssh" {
  security_group_id = aws_security_group.ec2_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_http" {
  security_group_id = aws_security_group.ec2_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # 모든 프로토콜 허용
}
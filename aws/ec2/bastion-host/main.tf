# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

resource "aws_security_group" "bastion_host_security_group" {
  name        = "${var.common.prefix}-bastion-host-security-group"
  vpc_id      = var.vpc_id

  tags        = {
    Name = "${var.common.prefix}-bastion-host-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_ssh" {
  security_group_id = aws_security_group.bastion_host_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound_all" {
  security_group_id = aws_security_group.bastion_host_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # 모든 프로토콜 허용
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "bastion_host" {
  ami             = var.ec2_option.ami
  instance_type   = var.ec2_option.instance_type
  key_name        = var.ec2_option.key_name

  subnet_id       = var.vpc_subnet_id
  vpc_security_group_ids = [
    aws_security_group.bastion_host_security_group.id
  ]

  associate_public_ip_address = true            # 퍼블릭 IP/DNS 주소 활성화

  tags            = {
    Name = "${var.common.prefix}-bastion-host"
  }
}
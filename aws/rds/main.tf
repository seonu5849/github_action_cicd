# rds
resource "aws_db_instance" "shinemuscat-rds" {
  identifier = "${ var.common.prefix }-rds" # DB 식별자 지정
  allocated_storage   = 20
  db_name             = "postgresql"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  username            = "postgres"
  password            = "12345678"
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true # 최종 스냅샷, 백업 남길지 말지 체크, true이면 최종 스냅샷을 생성하지 않고 RDS 인스턴스를 삭제

  # 네트워크 설정 (에: VPC 서브넷 그룹)
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.shinemuscat_db_subnet.name

 publicly_accessible = false # 퍼블릭 액세스 비활성화 (보안 강화)
#   publicly_accessible = true # 퍼블릭 엑세스 활성화 (로컬 접속)
}

# RDS 보안 그룹 설정
resource "aws_security_group" "rds_security_group" {
  name = "${ var.common.prefix }-rds-security-group"
  description = "Allow SSH to access RDS"
  vpc_id = var.vpc_id

  tags = {
    Name = "${ var.common.prefix }-rds-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_ssh" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # 모든 프로토콜 허용
}

# subnet 그룹 설정
# aws ec2 describe-subnets 을 통해서 서브넷 ID를 볼 수 있음
resource "aws_db_subnet_group" "shinemuscat_db_subnet" {
  name        = "${var.common.prefix}-db-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids = [for subnet in var.vpc_database_subnets : subnet.id]

  tags = {
    Name = "${var.common.prefix}-db-subnet-group"
  }
}
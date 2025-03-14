# rds
resource "aws_db_instance" "shinemuscat-rds" {
#   depends_on = [aws_instance.shinemuscat-ec2] # RDS와 EC2 간 종속성 설정
  identifier = "shinemuscat-rds" # DB 식별자 지정
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

#  publicly_accessible = false # 퍼블릭 액세스 비활성화 (보안 강화)
  publicly_accessible = true # 퍼블릭 엑세스 활성화 (로컬 접속)
}

# RDS 보안 그룹 설정
resource "aws_security_group" "rds_security_group" {
  name = "rds-security-group"
  description = "Allow EC2 to access RDS"

  # 보안그룹 설정
  ingress { # 들어오는 트래픽 (인바운드)
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
#     cidr_blocks = [format("%s/32", aws_instance.shinemuscat-ec2.private_ip)] # 단일 EC2 IP 허용
#     cidr_blocks = formatlist("%s/32", aws_instance.shinemuscat-ec2[*].private_ip) # 다중 EC2 IP 허용, format -> formatlist, [*] 추가
  }

  egress { #나가는 트래픽 (아웃바운드)
    from_port = 0
    to_port = 0
    protocol = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP로 나가는 트래픽 허용
  }
}

# subnet 그룹 설정
# aws ec2 describe-subnets 을 통해서 서브넷 ID를 볼 수 있음
resource "aws_db_subnet_group" "shinemuscat_db_subnet" {
  name        = "shinemuscat-db-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids = ["subnet-03fe278c3568f6df9", "subnet-034905c8f196154e9"]

  tags = {
    Name = "ShinemuscatDBSubnetGroup"
  }
}
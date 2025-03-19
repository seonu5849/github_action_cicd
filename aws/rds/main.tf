# #########################################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster.html#rds-multi-az-cluster
# https://docs.aws.amazon.com/ko_kr/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.RegionSupportAurora.html
# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster_postgres" {
  cluster_identifier      = "${var.common.prefix}-cluster" # 클러스터 식별자

  # db option
  engine                  = "aurora-postgresql"
  engine_version          = "16.4"
  database_name           = "postgres" # 생성될 데이터베이스 이름
  master_username         = "postgres"
  master_password         = "postgres1234#$"
  port = 5432
  db_cluster_parameter_group_name = "default.aurora-postgresql16" # DB 클러스터 전체에 적용되는 DB 옵션

  # network
  network_type              = "IPV4"
  availability_zones      = var.common.azs # DB 클러스터 인스턴스를 생성할 수 있는 가용영역 목록
  db_subnet_group_name = aws_db_subnet_group.shinemuscat_db_subnet.name # DB 서브넷
  vpc_security_group_ids = [aws_security_group.rds_security_group.id] # DB 보안그룹

  # backup
  backup_retention_period = 1 # 1일마다 백업
  preferred_backup_window = "02:00-03:00" # 백업시간
  storage_encrypted      = true

  apply_immediately   = true # false 이면 terraform 수정사항이 바로 적용되지 않음
  deletion_protection = false # true 이면 terraform destroy 실패함
  skip_final_snapshot = true # false 이면 terraform destroy 실패함

  tags = {
    Name = "${var.common.prefix}-aurora-postgres"
  }
}


# #########################################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
# Aurora Cluster Instance
resource "aws_rds_cluster_instance" "aurora_cluster_postgres_instances" {
  count              = 2 # Writer, Reader로 구성된다
  identifier         = "${var.common.prefix}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster_postgres.id
  engine             = aws_rds_cluster.aurora_cluster_postgres.engine
  engine_version     = aws_rds_cluster.aurora_cluster_postgres.engine_version
  instance_class = "db.t3.medium"
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
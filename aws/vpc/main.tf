# https://gurumee92.tistory.com/240 참고

# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true  # DNS 쿼리 지원 활성화
  enable_dns_hostnames = true  # DNS 호스트 이름 활성화

  tags = {
    Name = "${var.common.prefix}-vpc"
  }
}

# subnet (public)
resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id

  count             = length(var.common.azs)  # availability_zone의 수만큼 서브넷 생성
  availability_zone = var.common.azs[count.index]  # azs 배열에서 가용 영역 선택
  cidr_block        = local.subnet_cidrs.public[count.index]  # 해당 가용 영역의 cidr_block 선택

  map_public_ip_on_launch = true
  # 서브넷에 속하는 리소스는 모두 public으로 접속할 수 있도록

  tags = {
    Name = "${var.common.prefix}-${var.common.azs[count.index]}-public_subnet"
  }
}

# subnet (private)
resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id

  count             = length(var.common.azs)  # availability_zone의 수만큼 서브넷 생성
  availability_zone = var.common.azs[count.index]  # azs 배열에서 가용 영역 선택
  cidr_block        = local.subnet_cidrs.private[count.index]  # 해당 가용 영역의 cidr_block 선택

  map_public_ip_on_launch = true
  # 서브넷에 속하는 리소스는 모두 public으로 접속할 수 있도록

  tags = {
    Name = "${var.common.prefix}-${var.common.azs[count.index]}-private_subnet"
  }
}

# subnet (database)
resource "aws_subnet" "database_subnets" {
  vpc_id            = aws_vpc.vpc.id

  count             = length(var.common.azs)  # availability_zone의 수만큼 서브넷 생성
  availability_zone = var.common.azs[count.index]  # azs 배열에서 가용 영역 선택
  cidr_block        = local.subnet_cidrs.database[count.index]  # 해당 가용 영역의 cidr_block 선택

  map_public_ip_on_launch = true
  # 서브넷에 속하는 리소스는 모두 public으로 접속할 수 있도록

  tags = {
    Name = "${var.common.prefix}-${var.common.azs[count.index]}-database_subnet"
  }
}

#####################################################################
# 프라이빗 라우트 테이블 생성, nat gateway와 연결

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# 인터넷 게이트웨이
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.common.prefix} Internet Gateway"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# 라우트 테이블
# route table (public)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.common.prefix}-public-route-table"
  }
}

####################################################################
# 프라이빗 라우트 테이블 생성, nat gateway와 연결

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# Elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  # 퍼블릭 서브넷 아이디 입력. 해당 서브넷에 1개 생성하고, 다른 AZ에서 공유해서 사용하도록 한다.

  tags = {
    Name = "${var.common.prefix} NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# 프라이빗 라우트 테이블. Nat Gateway와 연결
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${var.common.prefix}-private-route-table"
  }
}

####################################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# 프라이빗 라우트 테이블, 데이터베이스 서브넷 연결
resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.common.prefix}-database-route-table"
  }
}

####################################################################
# 라우트 테이블 - 서브넷 연결
# public
resource "aws_route_table_association" "public_rta" {
  route_table_id = aws_route_table.public_rt.id
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

# private
resource "aws_route_table_association" "private_rta_a" {
  route_table_id = aws_route_table.private_rt.id
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

# database
resource "aws_route_table_association" "database_rta_a" {
  route_table_id = aws_route_table.database_rt.id
  count          = length(aws_subnet.database_subnets)
  subnet_id      = aws_subnet.database_subnets[count.index].id
}

# # network acl
# resource "aws_default_network_acl" "vpc_network_acl" {
#   default_network_acl_id = aws_vpc.vpc.default_network_acl_id
#
#   egress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 65535
#   }
#
#   ingress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
#
#   tags = {
#     Name = "${var.common.prefix} network acl"
#   }
# }
#
# # security group
# resource "aws_default_security_group" "default_sg" {
#   vpc_id = aws_vpc.vpc.id
#
#   ingress {
#     protocol    = "tcp"
#     from_port = 0
#     to_port   = 65535
#     cidr_blocks = [aws_vpc.vpc.cidr_block]
#   }
#
#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "${var.common.prefix} default_sg"
#     Description = "default security group"
#   }
# }
#
# resource "aws_security_group" "inhouse_sg" {
#   name        = "${var.common.prefix} pinhouse_sg"
#   description = "security group for inhouse"
#   vpc_id      = aws_vpc.vpc.id
#
#   ingress {
#     description = "For Inhouse ingress"
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = [
#       aws_vpc.vpc.cidr_block,
# #       format("%s/32", chomp(data.http.my_ip.body)), # 모든 IP로 나가는 트래픽 허용
#     ]
#   }
#
#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "${var.common.prefix} inhouse_sg"
#   }
# }
#
# resource "aws_security_group" "web_server_sg" {
#   name        = "${var.common.prefix} web_server_sg"
#   description = "security group for web server"
#   vpc_id      = aws_vpc.vpc.id
#
#   ingress {
#     description = "For http port"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     description = "For https port"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "web_server_sg"
#   }
# }
# https://gurumee92.tistory.com/240 참고

# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "shinemuscat-vpc"
  }
}

# subnet (public)
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "shinemuscat-public_subnet"
  }
}

# subnet (private)
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.10.101.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "shinemuscat-private_subnet"
  }
}

# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Shinemuscat Internet Gateway"
  }
}

# ngw
resource "aws_eip" "ngw_ip" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "Shinemuscat NAT Gateway"
  }
}

# route table (public)
resource "aws_default_route_table" "public_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Shinemuscat public route table"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_default_route_table.public_rt.id
}

# route table (private)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Shinemuscat private route table"
  }
}

resource "aws_route_table_association" "private_rta_a" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "private_rt_route" {
  route_table_id              = aws_route_table.private_rt.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.ngw.id
}

# network acl
resource "aws_default_network_acl" "vpc_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Shinemuscat network acl"
  }
}

# security group
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port = 0
    to_port   = 65535
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Shinemuscat default_sg"
    Description = "default security group"
  }
}

resource "aws_security_group" "inhouse_sg" {
  name        = "Shinemuscat pinhouse_sg"
  description = "security group for inhouse"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "For Inhouse ingress"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.vpc.cidr_block,
#       format("%s/32", chomp(data.http.my_ip.body)), # 모든 IP로 나가는 트래픽 허용
    ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Shinemuscat inhouse_sg"
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "Shinemuscat web_server_sg"
  description = "security group for web server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "For http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "For https port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_server_sg"
  }
}
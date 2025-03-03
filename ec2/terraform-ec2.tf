# terraform init -upgrade : 테라폼 명령어를 사용할 수 있는 환경으로 초기화 명령어
# terraform apply : 아래 tf파일을 바탕으로 aws에 인스턴스를 생성 명령어
# terraform destory : 아래 tf파일을 바탕으로 생성된 인스턴스를 종료 명령어

data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

variable "instance_names" {
  default = ["shinemuscat-cicd", "shinemuscat-app-1", "shinemuscat-app-2"]
}

terraform { # 각 공급자에 대해 소스 속성은 옵션 호스트 이름, 네임 스페이스 및 제공자 유형을 정의
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {            # 공급자 리소스를 관리, "aws"로 설정
  region = "ap-northeast-2" # 지역 = 서울
}

# 리소스 블록으로 인프라의 구성 요소를 정의하는 곳
# 리소스 유형은 "aws_instance", 인스턴스 이름은 "shinemuscat-ec2"으로 설정된다.
# EC2 인스턴스의 ID는 aws_instance.app_server로 생성
resource "aws_instance" "shinemuscat-ec2" {
  count = length(var.instance_names)
  ami           = "ami-024ea438ab0376a47" # ubuntu
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraform-key-pair.key_name # Key Pair 연결
  subnet_id = aws_subnet.public_subnet.id # terraform-vpc.tf에서 설정한 public_subnet 연결

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = var.instance_names[count.index] # 인스턴스 이름
  }
}

# 갖고 있는 key-pair를 등록
resource "aws_key_pair" "terraform-key-pair" {
#   public_key = file("/Users/seonoo/workspace/shinemuscat-mac.pub") # mac 경로
  public_key = file("C:/Users/window10/Documents/workspaces/shinemuscat.pub")
  key_name = "shinemuscat"

  tags = {
    description = "terraform key pair import"
  }
}

# ec2 접속을 위한 ssh 포트 개방
resource "aws_security_group" "ec2_security_group" {
  name = "ec2-security-group"
  description = "Allow SSH to access EC2"

  # 보안그룹 설정
  ingress { # 들어오는 트래픽 (인바운드)
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [format("%s/32", chomp(data.http.my_ip.body))] # 모든 IP로 나가는 트래픽 허용
    # body는 http 데이터 소스의 응답 본문(body)를 참조하기 위해 쓴 것
  }

  egress { #나가는 트래픽 (아웃바운드)
    from_port = 0
    to_port = 0
    protocol = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP로 나가는 트래픽 허용
  }
}

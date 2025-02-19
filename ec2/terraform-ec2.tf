# terraform init -upgrade : 테라폼 명령어를 사용할 수 있는 환경으로 초기화 명령어
# terraform apply : 아래 tf파일을 바탕으로 aws에 인스턴스를 생성 명령어
# terraform destory : 아래 tf파일을 바탕으로 생성된 인스턴스를 종료 명령어

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

  # IAM 사용자의 액세스 키와 시크릿 키
  access_key = "AKIAVDFFLX5AM2V7LWEP"
  secret_key = "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"
}

# 리소스 블록으로 인프라의 구성 요소를 정의하는 곳
# 리소스 유형은 "aws_instance", 인스턴스 이름은 "shinemuscat-ec2"으로 설정된다.
# EC2 인스턴스의 ID는 aws_instance.app_server로 생성
resource "aws_instance" "shinemuscat-ec2" {
  ami           = "ami-024ea438ab0376a47" # ubuntu
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance" # 인스턴스 이름
  }
}

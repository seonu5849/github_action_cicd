# terraform init -upgrade : 테라폼 명령어를 사용할 수 있는 환경으로 초기화 명령어
# terraform apply : 아래 tf파일을 바탕으로 aws에 인스턴스를 생성 명령어
# terraform destory : 아래 tf파일을 바탕으로 생성된 인스턴스를 종료 명령어

# https://developer.hashicorp.com/terraform/language/modules/syntax

terraform { # 각 공급자에 대해 소스 속성은 옵션 호스트 이름, 네임 스페이스 및 제공자 유형을 정의
  # 프로바이더 설치 준비 단계
  # "aws" 이름으로 프로바이더를 사용할거고, hashicorp/aws 프로바이더 설치해
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {            # 공급자 리소스를 관리, "aws"로 설정
  region = "ap-northeast-2" # 지역 = 서울
}

module "ec2" {
  source = "./ec2"
  common = local.common
  vpc_id = module.vpc.id
  vpc_subnet_id = module.vpc.public_subnets[0].id

  depends_on = [module.vpc]
}

# module "rds" {
#   source = "./rds"
#   common = local.common
#   vpc_id = module.vpc.id
#   vpc_database_subnets = module.vpc.database_subnets
#
#   depends_on = [module.ec2]
# }

module "vpc" {
  source = "./vpc"
  common = local.common
}

module "ecr" {
  source = "./ecr"
  common = local.common
}
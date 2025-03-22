
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
# respository를 생성하려면 AmazonEC2ContainerRegistryFullAccess 권한이 있어야 한다.
resource "aws_ecr_repository" "shinemuscat-ecr" {
  name                 = "ecr"
  image_tag_mutability = "MUTABLE" # 이미지 태그를 덮어쓸 수 있다.

  image_scanning_configuration {
    scan_on_push = true # 푸시할 때 스캔
  }

  force_delete = true # 이미지가 포함되어 있어도 저장소를 삭제

  encryption_configuration {
    encryption_type = "AES256" #default
  }

  tags = {
    Name = "${var.common.prefix}-ecr"
  }
}

#================================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
resource "aws_ecr_lifecycle_policy" "shinemuscat-ecr-lifecycle-policy" {
  repository = aws_ecr_repository.shinemuscat-ecr.name # 저장소 이름

  # 정책 문서, 태그가 지정된 이미지에 대한 정책
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

#============================================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
resource "aws_ecr_repository_policy" "shinemuscat-repo-policy" {
  repository = aws_ecr_repository.shinemuscat-ecr.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "Set the permission for ECR",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:CreateRepository",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}
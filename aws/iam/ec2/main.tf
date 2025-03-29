# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy
# AWS 관리형 IAM 정책 조회 (동적으로 역할 가져옴)
data "aws_iam_policy" "policy" {
  name = "AmazonEC2ContainerRegistryPowerUser" # ec2 -> ecr 접속 권한
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# EC2 인스턴스에 부여할 IAM 역할 생성
resource "aws_iam_role" "ec2-role" {
  name = "${var.common.prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.common.prefix}-ec2-role"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
# Attaches a Managed IAM Policy to an IAM role
resource "aws_iam_role_policy_attachment" "iam-attach" {
  role = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.policy.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy
# AWS 관리형 IAM 정책 조회 (동적으로 역할 가져옴)
data "aws_iam_policy" "policy" {
  name = "AmazonEC2ContainerRegistryPowerUser" # ec2 -> ecr 접속 권한
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
# Github OIDC Provider
resource "aws_iam_openid_connect_provider" "github-iam" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1" # GitHub OIDC 기본 Thumbprint
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# Github Action Role
resource "aws_iam_role" "github_iam_role" {
  depends_on = [aws_iam_openid_connect_provider.github-iam]
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Federated: aws_iam_openid_connect_provider.github-iam.arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": ["sts.amazonaws.com"]
          },
          "StringLike": {
            "token.actions.githubusercontent.com:sub": ["repo:${var.github_username}/${var.github_repository}:*"]
          }
        }
      }
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
# AmazonEC2ContainerRegistryPowerUser 정책을 IAM Role에 연결
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.github_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"

  depends_on = [aws_iam_role.github_iam_role]
}

resource "aws_iam_role_policy_attachment" "iam-codedeploy-attach" {
  role       = aws_iam_role.github_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"

  depends_on = [aws_iam_role.github_iam_role]
}
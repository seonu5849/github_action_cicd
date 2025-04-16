
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
          Service = [
            "ec2.amazonaws.com",
            "codedeploy.amazonaws.com"
          ]
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
resource "aws_iam_role_policy_attachment" "iam-ecr-attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"

  depends_on = [aws_iam_role.ec2-role]
}

resource "aws_iam_role_policy_attachment" "attach-ec2-fullaccess" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"

  depends_on = [aws_iam_role.ec2-role]
}


resource "aws_iam_role_policy_attachment" "iam-codedeploy-attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"

  depends_on = [aws_iam_role.ec2-role]
}

resource "aws_iam_role_policy_attachment" "attach-autoscaling" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"

  depends_on = [aws_iam_role.ec2-role]
}

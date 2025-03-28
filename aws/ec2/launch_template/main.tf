# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_launch_template" "ubuntu_with_docker" {
  name            = "ubuntu_with_docker"
  image_id        = "ami-024ea438ab0376a47"
  # 사용할 AMI ID
  #Canonical, Ubuntu, 24.04, amd64 noble image

  instance_type   = var.ec2_option.instance_type
  key_name        = var.ec2_option.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = filebase64("${path.module}/docker_with_jdk_setup.sh")

  tags = {
    Name = "${var.common.prefix}-launch-template-ubuntu-with-docker"
  }

}
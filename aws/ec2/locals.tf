
locals {
  ec2_option = {
    ami           = "ami-024ea438ab0376a47" # ubuntu
    instance_type = "t2.micro"
    key_name = "shinemuscat"
    username = "ubuntu"
  }
#   #   ec2 생성시 docker 설치 및 jdk 설치
#   ec2_init_setting = {
#     user_data = <<-EOF
#               #!/bin/bash
#               apt update -y && apt install -y docker.io
#               sudo chmod 666 /var/run/docker.sock
#               sudo apt update
#               sudo apt install openjdk-21-jre-headless -y
#               EOF
#   }

}
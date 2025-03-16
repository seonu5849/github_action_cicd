
module "ec2_security_group" {
  source = "./security_group"
  common = var.common
#   vpc_id = var.vpc_id
}

module "cicd" {
  source = "./instance"
  name = "cicd"
  common = var.common
  ec2_option = local.ec2_option
  security_group_id = module.ec2_security_group.id
  user_data = local.ec2_init_setting.user_data
  counts = 1
}

module "app" {
  source = "./instance"
  name = "app"
  common = var.common
  ec2_option = local.ec2_option
  security_group_id = module.ec2_security_group.id
  user_data = local.ec2_init_setting.user_data
  counts = 2
}
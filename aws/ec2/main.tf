
module "ec2_security_group" {
  source = "./security_group"
  common = var.common
  vpc_id = var.vpc_id
}

module "cicd" {
  source = "./instance"
  name = "cicd"
  common = var.common
  ec2_option = local.ec2_option
  security_group_id = module.ec2_security_group.id
  vpc_subnet_id = var.vpc_subnet_id
  counts = 1
}

module "app" {
  source = "./instance"
  name = "app"
  common = var.common
  ec2_option = local.ec2_option
  security_group_id = module.ec2_security_group.id
  vpc_subnet_id = var.vpc_subnet_id
  counts = 2
}
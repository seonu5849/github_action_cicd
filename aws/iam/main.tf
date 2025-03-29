
module "ec2-iam" {
  source = "./ec2"
  common = var.common
}

module "github-iam" {
  source = "./github-action"
  common = var.common
}
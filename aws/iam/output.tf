
output "github_action_role" {
  value = module.github-iam.role
}

output "ec2-role" {
  value = module.ec2-iam.role
}
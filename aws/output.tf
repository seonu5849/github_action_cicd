
output "rds" {
  description = "AURORA"
  value = <<EOF
    writer : ${module.rds.aurora_cluster_postgres.endpoint}
    reader : ${module.rds.aurora_cluster_postgres.reader_endpoint}
  EOF
}

output "bastion_host_public_ip" {
  description = "bastion host public ip"
  value = "ssh -i shinemuscat.pem ubuntu@${module.ec2.bastion_host.public_ip}"
}

# output "app_instances_private_ip" {
#   description = "apps private ip"
#   value = join("\n", [
#     for app in module.ec2.app_instance_ids : app.private_ip
#   ])
# }

output "ecr_url" {
  description = "ecr_url"
  value = module.ecr.this.repository_url
}

output "github_action_iam_arn" {
  description = "github_action_role_arn"
  value = module.iam.github_action_role.arn
}
output "bastion_host" {
  value = module.bastion_host.bastion_host
}

output "ec2_username" {
  value = local.ec2_option.username
}

output "app_instance_ids" {
  value = module.app.ids
}
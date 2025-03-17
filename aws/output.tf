

output "bastion_host_ssh_url" {
  value = join("\n", [
    "ssh ^",
    "-L 5433:${module.rds.rds_postgres.endpoint} ^",
    "-i C:\\Users\\window10\\Documents\\workspaces\\shinemuscat.pem ^",
    "${module.ec2.ec2_username}@${module.ec2.bastion_host.public_dns}"
  ])
}
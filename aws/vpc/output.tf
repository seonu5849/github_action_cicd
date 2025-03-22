
output "id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "database_subnets" {
  value = aws_subnet.database_subnets
}
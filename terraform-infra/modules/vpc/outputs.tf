# modules/vpc/outputs.tf

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "nat_gateway_id" {
  value       = var.enable_nat_gateway ? aws_nat_gateway.nat[0].id : null
  description = "NAT Gateway ID for private subnet internet access"
}


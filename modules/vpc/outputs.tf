output "vpc_id" {
  description = "ID of vpc"
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR of vpc"
  value = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "ID's of private subnets"
  value = module.vpc.private_subnets
}

output "public_subnets" {
  description = "ID's of public subnets"
  value = module.vpc.public_subnets
}

output "nat_public_IP's" {
  description = "Elastic IP's from NAT gateways"
  value = module.vpc.nat_public_ips
}

output "AZ's" {
  description = "Availability Zones"
  value = module.vpc.azs
}
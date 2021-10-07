#-----VPC module-----
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "tf-vpc"
  cidr = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway= false
  create_igw = true

  manage_default_route_table = true
  manage_default_network_acl = true
  
}

#-----Public subnet 1-----
#resource "aws_subnet" "public-subnet-1" {
#  vpc_id     = aws_vpc.tf-prod.id
#  cidr_block = "10.0.1.0/24"
#
#  tags = {
#    Name = "tf-public-1"
#  }
#}

#-----Public subnet 2-----
#resource "aws_subnet" "public-subnet-2" {
#  vpc_id     = aws_vpc.tf-prod.id
#  cidr_block = "10.0.2.0/24"
#
#  tags = {
#    Name = "tf-public-2"
#  }
#}

#-----Private subnet 1-----
#resource "aws_subnet" "private-subnet-1" {
#  vpc_id     = aws_vpc.tf-prod.id
#  cidr_block = "10.0.3.0/24"
#
#  tags = {
#    Name = "tf-private-1"
#  }
#}

#-----Private subnet 2-----
#resource "aws_subnet" "private-subnet-2" {
#  vpc_id     = aws_vpc.tf-prod.id
#  cidr_block = "10.0.4.0/24"
#
#  tags = {
#    Name = "tf-private-2"
#  }
#}

#-----Internet Gateway-----
#resource "aws_internet_gateway" "gw" {
#  vpc_id = aws_vpc.tf-prod.id
#
#  tags = {
#    Name = "tf-gw"
#  }
#}

#-----NAT Gateway 1-----
#resource "aws_nat_gateway" "gw1" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.example.id
#}

#-----NAT Gateway 2-----
#resource "aws_nat_gateway" "gw" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.example.id
#}
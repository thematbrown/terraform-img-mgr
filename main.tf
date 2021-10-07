terraform {
  backend "s3" {
      key = "vpc"
  }
}

module "vpc" {
    source = "./modules/vpc"    
}

module "app-asg" {
  source          = "./modules/app-asg"

  vpc_id          = module.vpc.vpc_id
  vpc             = module.vpc
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  #azs             = module.vpc.azs
}
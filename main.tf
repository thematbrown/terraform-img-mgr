terraform {
  backend "s3" {
      key = "vpc"
  }
}

module "VPC" {
    source = "./modules/vpc"    
}

#module "app" {
#  source = "./modules/app-asg"
#}
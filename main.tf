module "VPC" {
    source = "./modules/vpc"
    namespace = var.namespace
    
}
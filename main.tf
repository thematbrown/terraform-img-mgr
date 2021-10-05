module "VPC" {
    source = "./modules/networking"
    namespace = var.namespace
    
}
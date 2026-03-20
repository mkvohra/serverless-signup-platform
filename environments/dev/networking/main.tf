module "network" {
  source = "../../../modules/networking"

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          =  var.environment
  lambda_sg_name           = var.lambda_sg_name
  rds_sg_name              = var.rds_sg_name
  secrets_endpoint_sg_name = var.secrets_endpoint_sg_name
}
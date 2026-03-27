data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "stage/network/terraform.tfstate"
    region = "ap-south-1"
  }
}


data "terraform_remote_state" "bastion" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "stage/bastion/terraform.tfstate"
    region = "ap-south-1"
  }
}


module "database" {
  source = "../../../modules/database"

  project = var.project
  env     = var.env

  vpc_id                  = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids      = data.terraform_remote_state.networking.outputs.private_subnet_ids
  lambda_sg_id            = data.terraform_remote_state.networking.outputs.lambda_sg_id
  bastion_sg_id           = data.terraform_remote_state.bastion.outputs.bastion_sg_id

  db_name     = var.db_name
  db_username = var.db_username
}
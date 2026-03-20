data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "dev/networking/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "database" {
  source = "../../../modules/database"

  project = var.project
  env     = var.env

  private_subnet_ids      = data.terraform_remote_state.networking.outputs.private_subnet_ids
  db_security_group_id    = data.terraform_remote_state.networking.outputs.db_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
}
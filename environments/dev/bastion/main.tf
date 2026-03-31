data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "dev/network/terraform.tfstate"
    region = "ap-south-1"
  }
}


module "bastion" {
  source = "../../../modules/bastion"
  env                = var.env
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
}


data "terraform_remote_state" "networking" {

  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "dev/network/terraform.tfstate"
    region = "ap-south-1"
  }

}

data "terraform_remote_state" "database" {

  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "dev/database/terraform.tfstate"
    region = "ap-south-1"
  }

}

data "terraform_remote_state" "iam" {

  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "dev/iam/terraform.tfstate"
    region = "ap-south-1"
  }

}


module "lambda" {

  source = "../../../modules/lambda"

  project = var.project
  env     = var.env

  lambda_role_arn = data.terraform_remote_state.iam.outputs.lambda_role_arn

  artifact_bucket = var.artifact_bucket_name
  artifact_key    = dummy.zip
  lambda_subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  lambda_security_group_id = data.terraform_remote_state.networking.outputs.lambda_sg_id

}
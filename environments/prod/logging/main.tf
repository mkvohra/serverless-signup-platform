data "terraform_remote_state" "lambda" {

  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "prod/lambda/terraform.tfstate"
    region = "ap-south-1"
  }

}




module "logging" {
  source = "../../../modules/logging"

  lambda_function_name = data.terraform_remote_state.lambda.outputs.lambda_function_name

}
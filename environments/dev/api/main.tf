data "terraform_remote_state" "lambda" {
  backend = "s3"

  config = {
    bucket = "ssp-terraform-state-project"
    key    = "dev/lambda/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "api_gateway" {
  source = "../../../modules/api_gateway"

  api_name             = var.api_name
  stage_name           = var.stage_name
  lambda_invoke_arn    = data.terraform_remote_state.lambda.outputs.lambda_invoke_arn
  lambda_function_name = data.terraform_remote_state.lambda.outputs.lambda_function_name
}
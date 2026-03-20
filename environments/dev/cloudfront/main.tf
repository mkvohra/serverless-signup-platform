data "terraform_remote_state" "s3" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket"
    key    = "dev/s3_frontend/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "api" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket"
    key    = "dev/api_gateway/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "cloudfront" {
  source = "../../../modules/cloudfront"

  s3_bucket_domain     = data.terraform_remote_state.s3.outputs.bucket_regional_domain_name
  api_gateway_endpoint = data.terraform_remote_state.api.outputs.api_endpoint
  s3_bucket_arn        = data.terraform_remote_state.s3.outputs.bucket_arn
}
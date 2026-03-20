module "iam" {

  source = "../../../modules/iam"

  project_name = "serverless-app"
  environment  = "dev"
  oidc_provider_arn= var.oidc_provider_arn
}
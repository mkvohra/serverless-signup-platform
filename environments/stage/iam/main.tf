module "iam" {

  source = "../../../modules/iam"

  project_name = "serverless-app"
  environment  = "stage"
  oidc_provider_arn= var.oidc_provider_arn
}
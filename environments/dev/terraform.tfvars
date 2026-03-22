vpc_cidr    = "10.0.0.0/16"
environment = "dev"
region   = "ap-south-1"

private_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

lambda_sg_name           = "dev-lambda-sg"
rds_sg_name              = "dev-rds-sg"
secrets_endpoint_sg_name = "dev-secrets-endpoint-sg"

project = "serverless-signup"
env     = "dev"

db_name     = "usersdb"
db_username = "admin"

api_name   = "user-api-dev-test"
stage_name = "dev"

bucket_name = "muskan-dev-frontend-bucket"
artifact_bucket_name = "single-lambda-artifacts"


oidc_provider_arn = "arn:aws:iam::364868684572:oidc-provider/token.actions.githubusercontent.com"
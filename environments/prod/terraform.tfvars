vpc_cidr    = "10.2.0.0/16"
environment = "prod"
region   = "ap-south-1"

private_subnet_cidrs = [
  "10.2.1.0/24",
  "10.2.2.0/24"
]

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

lambda_sg_name           = "prod-lambda-sg"
rds_sg_name              = "prod-rds-sg"
secrets_endpoint_sg_name = "prod-secrets-endpoint-sg"

project = "serverless-signup"
env     = "prod"

db_name     = "usersdb"
db_username = "admin"

api_name   = "user-api"
stage_name = "prod"

bucket_name = "muskan-prod-frontend-bucket"
artifact_bucket_name = "single-lambda-artifacts"


oidc_provider_arn = "arn:aws:iam::364868684572:oidc-provider/token.actions.githubusercontent.com"
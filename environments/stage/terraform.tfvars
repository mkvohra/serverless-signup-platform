vpc_cidr    = "10.1.0.0/16"
environment = "stage"
region   = "ap-south-1"

private_subnet_cidrs = [
  "10.1.1.0/24",
  "10.1.2.0/24"
]

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

lambda_sg_name           = "stage-lambda-sg"
rds_sg_name              = "stage-rds-sg"
secrets_endpoint_sg_name = "stage-secrets-endpoint-sg"

project = "serverless-signup"
env     = "stage"

db_name     = "usersdb"
db_username = "admin"

api_name   = "user-api"
stage_name = "stage"

bucket_name = "muskan-stage-frontend-bucket"
artifact_bucket_name = "single-lambda-artifacts"


oidc_provider_arn = "arn:aws:iam::364868684572:oidc-provider/token.actions.githubusercontent.com"
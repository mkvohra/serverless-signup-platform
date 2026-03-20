module "s3_frontend" {
  source = "../../../modules/s3_frontend"

  bucket_name = var.bucket_name
  environment = var.environment
}
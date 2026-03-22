module "s3_frontend" {
  source = "../../../modules/s3"

  bucket_name = var.bucket_name
  environment = var.environment
}
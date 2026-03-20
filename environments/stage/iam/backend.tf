terraform {
  backend "s3" {
    bucket         = "ssp-terraform-state-project"
    key            = "stage/iam/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "ssp-tf-lock-table"
    encrypt        = true
  }
}
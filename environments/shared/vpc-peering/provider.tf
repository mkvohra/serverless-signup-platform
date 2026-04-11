terraform {
  backend "s3" {
    bucket = "ssp-terraform-state-project"
    key    = "shared/vpc-peering/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "ssp-tf-lock-table"
    encrypt        = true
  }
}


provider "aws" {
  region = "ap-south-1"
}
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
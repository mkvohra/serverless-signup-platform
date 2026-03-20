provider "aws" {
  region = "ap-south-1"
}
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
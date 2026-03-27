variable "vpc_cidr" {
  type = string
}

variable "environment" {
  type = string
}
variable "region" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "lambda_sg_name" {
  type = string
}

variable "rds_sg_name" {
  type = string
}

variable "secrets_endpoint_sg_name" {
  type = string
}
variable "project" {}
variable "env" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}


variable "instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {}
variable "db_username" {}

variable "lambda_sg_id" {}

variable "bastion_sg_id" {}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}
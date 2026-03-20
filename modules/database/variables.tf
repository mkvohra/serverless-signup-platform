variable "project" {}
variable "env" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_security_group_id" {}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {}
variable "db_username" {}
variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "artifact_key" {
  description = "Path to lambda artifact inside bucket"
  type        = string
}

variable "lambda_subnet_ids" {
  type = list(string)
}

variable "lambda_security_group_id" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}
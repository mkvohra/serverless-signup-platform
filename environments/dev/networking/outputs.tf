output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "route_table_id" {
  value = module.network.route_table_id
}

output "lambda_sg_id" {
  value = module.network.lambda_sg_id
}

output "rds_sg_id" {
  value = module.network.rds_sg_id
}

output "secrets_endpoint_sg_id" {
  value = module.network.secrets_endpoint_sg_id
}
output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
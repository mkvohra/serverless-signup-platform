resource "aws_cloudwatch_log_group" "lambda_logs" {

  name              = "/aws/lambda/${var.project}-${var.env}-lambda"
  retention_in_days = 14
}


resource "aws_lambda_function" "lambda" {

  function_name = "${var.project}-${var.env}-lambda"

  role    = var.lambda_role_arn
  handler = "handler.lambda_handler"
  runtime = "python3.11"

  s3_bucket = var.artifact_bucket
  s3_key    = var.artifact_key

  vpc_config {

    subnet_ids = var.lambda_subnet_ids

    security_group_ids = [
      var.lambda_security_group_id
    ]

  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name_override != "" ? var.db_secret_name_override : "${var.project}-${var.env}-db-credential"
    
      #DB_SECRET_NAME = "${var.project}-${var.env}-db-credential"
    }
  } 

}
resource "aws_iam_role" "lambda_execution_role" {

  name = "${var.project_name}-${var.environment}-lambda-role"

  # This policy defines WHO can assume this role.
  # In our case, AWS Lambda service itself assumes it.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy" "lambda_logging" {

  name = "lambda-logging"

  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",    # allows lambda to create log groups
          "logs:CreateLogStream",   # allows lambda to create streams
          "logs:PutLogEvents"      # allows lambda to write logs
        ]

        Resource = "*"
      }

    ]
  })
}



resource "aws_iam_role_policy" "lambda_secrets_access" {

  name = "lambda-secrets-access"

  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = "*"
      }

    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {

  role       = aws_iam_role.lambda_execution_role.name

  # AWS managed policy that allows ENI creation
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}



# Another iam roles (per environment) for ci/cd pipeline

resource "aws_iam_role" "github_actions_role" {

  name = "${var.project_name}-${var.environment}-github-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:mkvohra/serverless-signup-platform:*"
          }
        }

      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_admin" {

  role       = aws_iam_role.github_actions_role.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

}
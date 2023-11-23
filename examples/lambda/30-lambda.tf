data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "lambda-invoker"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "invoke_lambda" {
  name        = "invoke-lambda"
  path        = "/"
  description = "Invoke hello world lambda ${aws_lambda_function.test_lambda_function.function_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAuroraToExampleFunction",
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.test_lambda_function.arn
      }
    ]
  })
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/hello-lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda_function" {
  function_name    = "lambdaTest"
  filename         = "lambda_function_payload.zip"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.10"
  handler          = "lambda_function.lambda_handler"
  timeout          = 10
}

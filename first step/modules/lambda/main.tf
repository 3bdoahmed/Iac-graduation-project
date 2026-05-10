data "archive_file" "lambda_zip" {

  type = "zip"

  source_file = "${path.root}/lambda/lambda_function.py"

  output_path = "${path.root}/lambda/lambda_function.zip"
}

resource "aws_lambda_function" "s3_monitoring" {

  function_name = "s3-monitoring-copy"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = var.lambda_role_arn
  handler = "lambda_function.lambda_handler"

  runtime = "python3.12"

  timeout = 30

  environment {
    variables = {
      SNS_TOPIC_ARN     = var.sns_topic_arn
      MONITORING_BUCKET = var.monitoring_bucket
    }
  }
}
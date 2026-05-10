########################################
# ZIP
########################################

data "archive_file" "lambda_zip" {

  type = "zip"

  source_file = "${path.root}/lambda/api-reader/lambda_function.py"

  output_path = "${path.module}/${var.function_name}.zip"
}

########################################
# LAMBDA
########################################

resource "aws_lambda_function" "api_lambda" {

  function_name = var.function_name

  filename = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = var.lambda_role_arn

  handler = "lambda_function.lambda_handler"

  runtime = "python3.12"

  timeout = 30

  environment {

    variables = {

      TABLE_NAME = var.table_name
    }
  }
}
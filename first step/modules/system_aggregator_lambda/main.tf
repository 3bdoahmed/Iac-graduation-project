########################################
# ZIP
########################################

data "archive_file" "lambda_zip" {

  type = "zip"

  source_file = "${path.root}/lambda/system-aggregator/lambda_function.py"

  output_path = "${path.module}/system_aggregator.zip"
}

########################################
# LAMBDA
########################################

resource "aws_lambda_function" "system_aggregator" {

  function_name = "system-aggregator"

  filename = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = var.lambda_role_arn

  handler = "lambda_function.lambda_handler"

  runtime = "python3.12"

  timeout = 30

  environment {

    variables = {

      BATTERY_TABLE = var.battery_table

      SOLAR_TABLE = var.solar_table

      SUMMARY_TABLE = var.summary_table
    }
  }
}
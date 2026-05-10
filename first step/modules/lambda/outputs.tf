output "lambda_function_arn" {
  value = aws_lambda_function.s3_monitoring.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.s3_monitoring.function_name
}
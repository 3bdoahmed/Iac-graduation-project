output "lambda_name" {
  value = aws_lambda_function.system_aggregator.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.system_aggregator.arn
}
output "lambda_name" {
  value = aws_lambda_function.api_lambda.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.api_lambda.arn
}
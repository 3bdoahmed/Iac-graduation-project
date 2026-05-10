#########################################
# HTTP API
#########################################

resource "aws_apigatewayv2_api" "http_api" {

  name = var.api_name

  protocol_type = "HTTP"
}

#########################################
# INTEGRATION
#########################################

resource "aws_apigatewayv2_integration" "lambda_integration" {

  api_id = aws_apigatewayv2_api.http_api.id

  integration_type = "AWS_PROXY"

  integration_uri = var.lambda_function_arn

  integration_method = "POST"

  payload_format_version = "2.0"
}

#########################################
# ROUTE
#########################################

resource "aws_apigatewayv2_route" "route" {

  api_id = aws_apigatewayv2_api.http_api.id

  route_key = "GET ${var.route_key}"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

#########################################
# STAGE
#########################################

resource "aws_apigatewayv2_stage" "dev" {

  api_id = aws_apigatewayv2_api.http_api.id

  name = "$default"

  auto_deploy = true
}

#########################################
# PERMISSION
#########################################

resource "aws_lambda_permission" "api_gw" {

  statement_id = "AllowExecutionFromAPIGateway-${var.api_name}"

  action = "lambda:InvokeFunction"

  function_name = var.lambda_function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
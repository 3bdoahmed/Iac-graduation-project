############################
# S3 Module
############################

module "s3" {
  source = "./modules/s3"
}

############################
# SNS Module
############################

module "sns" {
  source = "./modules/sns"

  notification_email = var.notification_email
}

############################
# IAM Module
############################

module "iam" {
  source        = "./modules/iam"
  sns_topic_arn = module.sns.topic_arn
  battery_table = module.dynamodb.battery_table_name
  solar_table   = module.dynamodb.solar_table_name
  summary_table = module.dynamodb.system_status_table_name
}

############################
# Lambda Module
############################

module "lambda" {
  source = "./modules/lambda"

  lambda_role_arn = module.iam.lambda_role_arn
  sns_topic_arn   = module.sns.topic_arn

  source_buckets    = module.s3.source_buckets
  monitoring_bucket = module.s3.monitoring_bucket
}

############################
# Lambda Permission
############################

resource "aws_lambda_permission" "allow_s3" {

  for_each = toset(module.s3.source_buckets)

  statement_id  = "AllowExecutionFromS3-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "s3.amazonaws.com"

  source_arn = "arn:aws:s3:::${each.value}"
}

############################
# S3 Event Notifications
############################

resource "aws_s3_bucket_notification" "bucket_notification" {

  for_each = toset(module.s3.source_buckets)

  bucket = each.value

  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}


############################
# DynamoDB Module
############################

module "dynamodb" {
  source = "./modules/dynamodb"
}

########################################
# SYSTEM AGGREGATOR LAMBDA
########################################

module "system_aggregator_lambda" {

  source = "./modules/system_aggregator_lambda"

  lambda_role_arn = module.iam.lambda_role_arn

  battery_table = module.dynamodb.battery_table_name

  solar_table = module.dynamodb.solar_table_name

  summary_table = module.dynamodb.system_status_table_name
}

########################################
# Jeson API LAMBDA
########################################

module "solar_data_api" {

  source = "./modules/api_lambda"

  function_name = "solar_data_api"

  table_name = module.dynamodb.solar_table_name

  lambda_role_arn = module.iam.lambda_role_arn
}

module "battery_data_api" {

  source = "./modules/api_lambda"

  function_name = "battery_data_api"

  table_name = module.dynamodb.battery_table_name

  lambda_role_arn = module.iam.lambda_role_arn
}

module "system_status_api" {

  source = "./modules/api_lambda"

  function_name = "system-aggregator-api"

  table_name = module.dynamodb.system_status_table_name

  lambda_role_arn = module.iam.lambda_role_arn
}

########################################
# API battery, solar, system
########################################

module "battery_api_gateway" {

  source = "./modules/api_gateway"

  api_name = "Api_battery"

  lambda_function_arn = module.battery_data_api.lambda_arn

  lambda_function_name = module.battery_data_api.lambda_name

  route_key = "/battery"
}

module "solar_api_gateway" {

  source = "./modules/api_gateway"

  api_name = "Api_solarPanal"

  lambda_function_arn = module.solar_data_api.lambda_arn

  lambda_function_name = module.solar_data_api.lambda_name

  route_key = "/solar"
}

module "system_api_gateway" {

  source = "./modules/api_gateway"

  api_name = "Api_systemsummry"

  lambda_function_arn = module.system_status_api.lambda_arn

  lambda_function_name = module.system_status_api.lambda_name

  route_key = "/system"
}
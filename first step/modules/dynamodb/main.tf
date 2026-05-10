########################################
# battery_data
########################################

resource "aws_dynamodb_table" "battery_data" {

  name         = "battery_data"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "battery_id"
  range_key = "inverter_id"

  attribute {
    name = "battery_id"
    type = "S"
  }

  attribute {
    name = "inverter_id"
    type = "S"
  }

  deletion_protection_enabled = false

  table_class = "STANDARD"
}

########################################
# solar_data
########################################

resource "aws_dynamodb_table" "solar_data" {

  name         = "solar_data"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "inverter_id"
  range_key = "panel_id"

  attribute {
    name = "inverter_id"
    type = "S"
  }

  attribute {
    name = "panel_id"
    type = "S"
  }

  deletion_protection_enabled = false

  table_class = "STANDARD"
}

########################################
# system_status
########################################

resource "aws_dynamodb_table" "system_status" {

  name         = "system_status"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "summaryID"
  range_key = "Timestamp"

  attribute {
    name = "summaryID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  deletion_protection_enabled = false

  table_class = "STANDARD"
}
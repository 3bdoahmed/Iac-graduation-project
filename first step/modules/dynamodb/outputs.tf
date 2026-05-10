output "battery_table_name" {
  value = aws_dynamodb_table.battery_data.name
}

output "solar_table_name" {
  value = aws_dynamodb_table.solar_data.name
}

output "system_status_table_name" {
  value = aws_dynamodb_table.system_status.name
}
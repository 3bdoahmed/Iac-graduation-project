output "battery_api_url" {

  value = "${module.battery_api_gateway.api_endpoint}/battery"
}

output "solar_api_url" {

  value = "${module.solar_api_gateway.api_endpoint}/solar"
}

output "system_api_url" {

  value = "${module.system_api_gateway.api_endpoint}/system"
}
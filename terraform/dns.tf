resource "azurerm_private_dns_zone" "private_function" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.fa.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_a_record" "private_function" {
  name                = data.namep_azure_name.function_app_private.result
  zone_name           = azurerm_private_dns_zone.private_function.name
  resource_group_name = azurerm_resource_group.fa.name
  ttl                 = 10
  records             = [azurerm_private_endpoint.private_function.private_service_connection[0].private_ip_address]
}
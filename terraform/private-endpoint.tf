resource "azurerm_private_endpoint" "private_function" {
  name                = data.namep_azure_name.pe_function.result
  location            = azurerm_resource_group.fa.location
  resource_group_name = azurerm_resource_group.fa.name
  subnet_id           = azurerm_subnet.spoke1-default.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "spoke1-fa"
    private_connection_resource_id = azurerm_linux_function_app.fa-private.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

}
resource "azurerm_application_insights" "fa" {
  name                = data.namep_azure_name.ai.result
  location            = var.location
  resource_group_name = azurerm_resource_group.fa.name
  application_type    = "web"
}
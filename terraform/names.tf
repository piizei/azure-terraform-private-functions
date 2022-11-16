data "namep_azure_name" "function_app_rg" {
  name     = "function-app"
  type     = "azurerm_resource_group"
}

data "namep_azure_name" "function_app_sa" {
  name     = "fa"
  type     = "azurerm_storage_account"
}

data "namep_azure_name" "function_app_plan" {
  name     = "fa"
  type     = "azurerm_app_service_plan"
}

data "namep_azure_name" "function_app" {
  name     = local.env # Needs to be globally unique...
  type     = "azurerm_function_app"
}
data "namep_azure_name" "function_app_private" {
  name     = "${local.env}-private" # Needs to be globally unique...
  type     = "azurerm_function_app"
}

data "namep_azure_name" "ai" {
  name     = "fa"
  type     = "azurerm_application_insights"
}

data "namep_azure_name" "hub" {
  name     = "hub"
  type     = "azurerm_virtual_network"
}

data "namep_azure_name" "spoke1" {
  name     = "spoke1"
  type     = "azurerm_virtual_network"
}

data "namep_azure_name" "hubnsg" {
  name     = "hub-default"
  type     = "azurerm_network_security_group"
}

data "namep_azure_name" "spoke1-default" {
  name     = "spoke1-default"
  type     = "azurerm_network_security_group"
}

data "namep_azure_name" "bastion" {
  name     = "bastion"
  type     = "azurerm_bastion_host"
}

data "namep_azure_name" "bastionnsg" {
  name     = "bastion"
  type     = "azurerm_network_security_group"
}

data "namep_azure_name" "pipbastion" {
  name     = "bastion"
  type     = "azurerm_public_ip"
}

data "namep_azure_name" "hub_spoke1" {
  name     = "hub-spoke1"
  type     = "azurerm_virtual_network_peering"
}

data "namep_azure_name" "spoke1_hub" {
  name     = "spoke1-hub"
  type     = "azurerm_virtual_network_peering"
}

data "namep_azure_name" "pe_function" {
  name     = "fa"
  type     = "azurerm_private_endpoint"
}
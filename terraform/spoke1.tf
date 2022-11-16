resource "azurerm_virtual_network" "spoke1" {
  name                = data.namep_azure_name.spoke1.result
  address_space       = ["10.10.0.0/16"]
  resource_group_name = azurerm_resource_group.fa.name
  location            = azurerm_resource_group.fa.location
  tags                = local.common_tags
}

resource "azurerm_subnet" "spoke1-default" {
  name                                           = "default"
  resource_group_name                            = azurerm_resource_group.fa.name
  virtual_network_name                           = azurerm_virtual_network.spoke1.name
  address_prefixes                               = ["10.10.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "spoke1-function" {
  name                                           = "function"
  resource_group_name                            = azurerm_resource_group.fa.name
  virtual_network_name                           = azurerm_virtual_network.spoke1.name
  address_prefixes                               = ["10.10.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }


}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke1" {
  name                  = "spoke1"
  resource_group_name   = azurerm_resource_group.fa.name
  private_dns_zone_name = azurerm_private_dns_zone.private_function.name
  virtual_network_id    = azurerm_virtual_network.spoke1.id
  tags                  = local.common_tags
}

resource "azurerm_virtual_network_peering" "spoke1-hub" {
  name                         = data.namep_azure_name.spoke1_hub.result
  resource_group_name          = azurerm_resource_group.fa.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}


resource "azurerm_network_security_group" "spoke1-default" {
  name                = data.namep_azure_name.spoke1-default.result
  location            = azurerm_resource_group.fa.location
  resource_group_name = azurerm_resource_group.fa.name

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-a-spoke1" {
  subnet_id                 = azurerm_subnet.spoke1-default.id
  network_security_group_id = azurerm_network_security_group.spoke1-default.id
}
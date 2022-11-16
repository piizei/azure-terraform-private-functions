resource "azurerm_virtual_network" "hub" {
  name                = data.namep_azure_name.hub.result
  address_space       = ["10.12.0.0/16"]
  resource_group_name = azurerm_resource_group.fa.name
  location            = azurerm_resource_group.fa.location
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "hub"
  resource_group_name   = azurerm_resource_group.fa.name
  private_dns_zone_name = azurerm_private_dns_zone.private_function.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  tags                  = local.common_tags
}

resource "azurerm_subnet" "hub_default" {
  name                                           = "default"
  resource_group_name                            = azurerm_resource_group.fa.name
  virtual_network_name                           = azurerm_virtual_network.hub.name
  address_prefixes                               = ["10.12.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "bastion_subnet" {
  name                                           = "AzureBastionSubnet"
  resource_group_name                            = azurerm_resource_group.fa.name
  virtual_network_name                           = azurerm_virtual_network.hub.name
  address_prefixes                               = ["10.12.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}


resource "azurerm_network_security_group" "hub-default" {
  name                = data.namep_azure_name.hubnsg.result
  location            = azurerm_resource_group.fa.location
  resource_group_name = azurerm_resource_group.fa.name

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 650
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 651
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 655
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_network_security_group" "bastion" {
  name                = data.namep_azure_name.bastionnsg.result
  location            = azurerm_resource_group.fa.location
  resource_group_name = azurerm_resource_group.fa.name

  security_rule {
    name                       = "AllowHttpsInBound"
    priority                   = 600
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 650
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 651
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 655
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureCloudOutBound"
    priority                   = 640
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }


  security_rule {
    name                       = "AllowVnetOutBound"
    priority                   = 650
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 651
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 660
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = data.namep_azure_name.bastion.result
  location            = azurerm_resource_group.fa.location
  resource_group_name = azurerm_resource_group.fa.name
  tags                = local.common_tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = data.namep_azure_name.pipbastion.result
  resource_group_name = azurerm_resource_group.fa.name
  location            = azurerm_resource_group.fa.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}


resource "azurerm_subnet_network_security_group_association" "nsg-a-bastion" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}



resource "azurerm_subnet_network_security_group_association" "nsg-a-hub" {
  subnet_id                 = azurerm_subnet.hub_default.id
  network_security_group_id = azurerm_network_security_group.hub-default.id
}



resource "azurerm_virtual_network_peering" "hub-spoke1" {
  name                         = data.namep_azure_name.hub_spoke1.result
  resource_group_name          = azurerm_resource_group.fa.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}
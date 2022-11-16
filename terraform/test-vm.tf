resource "random_password" "password" {
  count = var.deploy_test_vm ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%*()-_=+[]{}:?"
}


#Spoke 1
resource "azurerm_network_interface" "vm1" {
  count = var.deploy_test_vm ? 1 : 0
  name                = "vm1nic"
  resource_group_name = azurerm_resource_group.fa.name
  location            = azurerm_resource_group.fa.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke1-default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke1test" {
  count = var.deploy_test_vm ? 1 : 0
  name                            = "spoke1-test-vm"
  resource_group_name             = azurerm_resource_group.fa.name
  location                        = azurerm_resource_group.fa.location
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  admin_password                  = random_password.password[0].result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm1[0].id]
  tags                            = local.common_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm1" {
  count = var.deploy_test_vm ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.spoke1test[0].id
  location           = azurerm_resource_group.fa.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "Central Europe Standard Time"

  notification_settings {
    enabled = false
  }

}

resource "azurerm_virtual_machine_extension" "vm1" {
  count = var.deploy_test_vm ? 1 : 0
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.spoke1test[0].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && sudo apt-get install -y docker.io"
    }
SETTINGS

  tags = local.common_tags
}


output "password" {
  value     = try(random_password.password[0].result, "")
  sensitive = true
}

output "username" {
  value     = try(azurerm_linux_virtual_machine.spoke1test[0].admin_username, "")
  sensitive = false
}
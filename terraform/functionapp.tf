resource "azurerm_resource_group" "fa" {
  name     = data.namep_azure_name.function_app_rg.result
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "fa" {
  name                     = data.namep_azure_name.function_app_sa.result
  resource_group_name      = azurerm_resource_group.fa.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_service_plan" "fa" {
  name                = data.namep_azure_name.function_app_plan.result
  location            = var.location
  resource_group_name = azurerm_resource_group.fa.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }


}

# This function app is reachable from internet, but is integrated with VNET (calls private services)
resource "azurerm_linux_function_app" "fa" {
  name                          = data.namep_azure_name.function_app.result
  location                      = var.location
  resource_group_name           = azurerm_resource_group.fa.name
  service_plan_id               = azurerm_service_plan.fa.id
  storage_account_name          = azurerm_storage_account.fa.name
  storage_uses_managed_identity = true
  https_only                    = true

  site_config {
    always_on = true
    application_stack {
      python_version = "3.9"
    }
  }

  virtual_network_subnet_id = azurerm_subnet.spoke1-function.id


  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "PYTHON_ENABLE_WORKER_EXTENSIONS"       = "1"
    "AzureWebJobsFeatureFlags"              = "EnableWorkerIndexing"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.fa.connection_string
    "BUILD_FLAGS"                           = "UseExpressBuild"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"        = "1"
    "ENABLE_ORYX_BUILD"                     = "true",
    "PYTHON_ISOLATE_WORKER_DEPENDENCIES"    = "1",
    # This is the address of the private function app (which we call from the public function that is vnet integrated)
    "PRIVATE_FUNCTION_ENDPOINT"             = "https://${azurerm_linux_function_app.fa-private.default_hostname}/api/HttpExample"

  }



  tags = local.common_tags
  lifecycle {
    ignore_changes = [
      app_settings.WEBSITE_RUN_FROM_ZIP,
      app_settings.WEBSITE_RUN_FROM_PACKAGE,
      app_settings.MACHINEKEY_DecryptionKey,
      app_settings.WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,
      app_settings.WEBSITE_CONTENTSHARE,
      app_settings.ENABLE_ORYX_BUILD,
      app_settings.SCM_DO_BUILD_DURING_DEPLOYMENT,
      app_settings.XDG_CACHE_HOME,
      app_settings.BUILD_FLAGS,
      app_settings.APPLICATIONINSIGHTS_CONNECTION_STRING
    ]
  }

  identity {
    type = "SystemAssigned"
  }
}

# This function app is not reachable from internet, just from inside the vnet
resource "azurerm_linux_function_app" "fa-private" {
  name                          = data.namep_azure_name.function_app_private.result
  location                      = var.location
  resource_group_name           = azurerm_resource_group.fa.name
  service_plan_id               = azurerm_service_plan.fa.id
  storage_account_name          = azurerm_storage_account.fa.name
  storage_uses_managed_identity = true
  https_only                    = true

  site_config {
    always_on = true
    application_stack {
      docker {
        registry_url = "docker.io"
        image_name   = "piizei/azurefunctionshello"
        image_tag    = "latest"
      }
    }
  }

  virtual_network_subnet_id = azurerm_subnet.spoke1-function.id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.fa.connection_string

  }

  tags = local.common_tags
  lifecycle {
    ignore_changes = [
      app_settings.MACHINEKEY_DecryptionKey,
      app_settings.WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,
      app_settings.WEBSITE_CONTENTSHARE,
      app_settings.APPLICATIONINSIGHTS_CONNECTION_STRING
    ]
  }

}

# System assigned identity RBAC for the function app to read it's storage account
resource "azurerm_role_assignment" "fa" {
  scope                = azurerm_storage_account.fa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.fa.identity[0].principal_id
}

output "function-app-name" {
  value     = data.namep_azure_name.function_app.result
  sensitive = false
}
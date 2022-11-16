locals {
  env = coalesce(var.environment, terraform.workspace)
  common_tags = {
    environment = coalesce(var.environment, terraform.workspace)
    owner       = var.owner
    version     = var.release_version
  }
}

provider "namep" {
  default_location = var.location
  extra_tokens = {
    env = local.env
  }
  # Using the default formatting #{SLUG}#{SHORT_LOC}#{NAME} for most resources, but its confusing for RGs
  # And to get globally unique function app names, we use ENV there as well
  resource_formats = {
    azurerm_resource_group     = "#{SLUG}-#{SHORT_LOC}-#{ENV}-#{NAME}"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

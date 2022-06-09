terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  subscription_id = var.subs_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
#  version = "=3.0.0"
  features {}
}
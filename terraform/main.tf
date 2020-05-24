provider "azurerm" {
  version = "=2.5.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
    name     = "myExampleGroup"
    location = "westeurope"
}
terraform {
  backend "azurerm" {
    container_name = "terraformstate"
    key            = "myProject-shared.terraform.tfstate"
  }
}

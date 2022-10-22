terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.28.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

variable "tags" {
  type = map(string)
  default = {
    ENVIRONMENT = "TEST"
    OWNER       = "DEVOPS"
    ROLE        = "MSSQL"
    CC          = "AZ DEV TEST"
  }
}

resource "azurerm_resource_group" "sql" {
  name     = "rg-test-sql"
  location = "eastus"

  tags = var.tags
}

resource "azurerm_virtual_network" "net" {
  name                = "vnetsql"
  location            = azurerm_resource_group.sql.location
  resource_group_name = azurerm_resource_group.sql.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []

  tags = var.tags
}

resource "azurerm_subnet" "net" {
  name                 = "sqlt"
  resource_group_name  = azurerm_resource_group.sql.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    azurerm_virtual_network.net
  ]
}

module "vm_sqlserver" {
  source              = "../mvx-modulo-vm_sql"
  vm_name             = "VMSQL1"
  resource_group_name = azurerm_resource_group.sql.name
  size_name           = "Standard_B2ms"
  vm_adm_user         = "sqladmin"
  vm_adm_password     = "Smegma2319_3231#$#!Gold@12"


  vnet_subnet = azurerm_subnet.net.name
  vnet_name   = azurerm_virtual_network.net.name
  vnet_rg     = azurerm_resource_group.sql.name


  sku_name    = "sqldev" // enterprise, standard, sqldev, web
  sku_offer   = "sql2016sp3-ws2019"
  sku_version = "13.2.220913"

  tags = var.tags

  enable_sql_automate_patching = true

}

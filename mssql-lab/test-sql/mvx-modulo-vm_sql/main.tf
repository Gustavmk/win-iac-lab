
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "main_vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

data "azurerm_subnet" "main" {
  name                 = var.vnet_subnet
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.vm_name}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = var.size_name
  admin_username      = var.vm_adm_user
  admin_password      = var.vm_adm_password
  timezone            = "E. South America Standard Time"

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  winrm_listener {
    protocol = "Http"
  }

  os_disk {
    name                 = "DISK_${var.vm_name}_OS"
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size
  }

  source_image_reference {
    publisher = var.sku_publisher
    offer     = var.sku_offer
    sku       = var.sku_name
    version   = var.sku_version
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
      identity
    ]
  }

  depends_on = [
    azurerm_network_interface.main
  ]
}

resource "azurerm_managed_disk" "data" {
  name                 = "DISK_${var.vm_name}_DATA_1"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "64"

  tags = var.tags
}

resource "azurerm_managed_disk" "log" {
  name                 = "DISK_${var.vm_name}_LOG_1"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "64"

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  managed_disk_id    = azurerm_managed_disk.data.id
  virtual_machine_id = azurerm_virtual_machine.main.id
  lun                = "1"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "log" {
  managed_disk_id    = azurerm_managed_disk.log.id
  virtual_machine_id = azurerm_virtual_machine.main.id
  lun                = "2"
  caching            = "ReadWrite"
}
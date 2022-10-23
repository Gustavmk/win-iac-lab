
resource "azurerm_virtual_machine_extension" "join_ad" {
  count = var.enable_join_ad ? 1 : 0

  name                 = "vm-join-ad"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = jsonencode({
    Name    = var.join_ad_domain_name
    OUPath  = var.join_ad_ou_path
    User    = var.join_ad_user
    Restart = true
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.join_ad_password
  })

  depends_on = [
    azurerm_mssql_virtual_machine.main
  ]

}

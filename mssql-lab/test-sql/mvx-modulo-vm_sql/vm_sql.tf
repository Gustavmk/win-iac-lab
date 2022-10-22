
resource "azurerm_mssql_virtual_machine" "main" {
  virtual_machine_id    = azurerm_windows_virtual_machine.main.id
  sql_license_type      = var.sql_license_type
  r_services_enabled    = var.r_services_enabled
  sql_connectivity_port = 1433
  sql_connectivity_type = "PRIVATE"

  sql_connectivity_update_password = "Password1234!"
  sql_connectivity_update_username = "sqllogin"


  // TODO CRIAR AS VARIABLLES
  /*
  key_vault_credential {
    name                     = "${var.vm_name}-AKVCred"
    key_vault_url            = data.azurerm_key_vault.hostingsqlkv.vault_uri
    service_principal_name   = data.azurerm_key_vault_secret.readerid.value
    service_principal_secret = data.azurerm_key_vault_secret.spreadersecret.value
  }
  */

  // TODO CRIAR AS VARIABLLES
  storage_configuration {
    disk_type             = var.sql_storage_sqldisktype
    storage_workload_type = var.sql_storage_workloadtype
    data_settings {
      default_file_path = "F:\\data"
      luns              = (local.datadisk_count == "1") ? [1] : range(1, local.datadisk_count + 1)
    }
    log_settings {
      default_file_path = "G:\\logs"
      luns              = (local.logdisk_count == "1") ? [10] : range(10, (local.logdisk_count + 10))
    }
    temp_db_settings {
      default_file_path = "D:\\SQLTemp"
      luns              = [] // If you use an empty list ([]), it will pass through the validation and the tempdb will be created inside the temporary disk as desired.
    }
  }

  // TODO CRIAR AS VARIABLLES
  auto_backup {
    encryption_enabled = false
    #encryption_password = null
    manual_schedule                 = "Manual"
    retention_period_in_days        = 15
    storage_blob_endpoint           = ""
    storage_account_access_key      = ""
    system_databases_backup_enabled = true

    manual_schedule {
      full_backup_frequency           = "Weekly"
      full_backup_start_hour          = "23"
      full_backup_window_in_hours     = "7"
      log_backup_frequency_in_minutes = "15"
    }

  }

  dynamic "auto_patching" {
    for_each = local.SqlServerConfig.sqlpatchingConfig.patchingEnabled == false ? [] : list(local.SqlServerConfig.sqlpatchingConfig)
    content {
      day_of_week                            = auto_patching.value.dayOfWeek
      maintenance_window_duration_in_minutes = auto_patching.value.maintenanceWindowDuration
      maintenance_window_starting_hour       = auto_patching.value.maintenanceWindowStartingHour
    }
  }


}


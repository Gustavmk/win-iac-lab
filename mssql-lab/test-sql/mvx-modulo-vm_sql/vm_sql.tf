
resource "azurerm_mssql_virtual_machine" "main" {
  virtual_machine_id    = azurerm_windows_virtual_machine.main.id
  sql_license_type      = var.sql_license_type
  r_services_enabled    = var.r_services_enabled
  sql_connectivity_port = var.sql_connectivity_port
  sql_connectivity_type = var.sql_connectivity_type

  sql_connectivity_update_username = var.sql_login_username
  sql_connectivity_update_password = var.sql_login_password

  dynamic "key_vault_credential" {
    for_each = var.enable_sql_key_vault_integration == false ? [] : [1]
    content {
      name                     = key_vault_credential.value.name
      key_vault_url            = key_vault_credential.value.vault_uri
      service_principal_name   = key_vault_credential.value.service_principal_name
      service_principal_secret = key_vault_credential.value.service_principal_secret
    }
  }
  /*
  key_vault_credential {
    name                     = "${var.vm_name}-AKVCred"
    key_vault_url            = data.azurerm_key_vault.hostingsqlkv.vault_uri
    service_principal_name   = data.azurerm_key_vault_secret.readerid.value
    service_principal_secret = data.azurerm_key_vault_secret.spreadersecret.value
  }
  */

  storage_configuration {

    disk_type             = var.sql_disk_type
    storage_workload_type = var.sql_storage_workload_type

    data_settings {
      default_file_path = local.SqlStorageConfig.data_storage.default_file_path
      #luns              = (local.SqlStorageConfig.data_storage.count == "1") ? [1] : range(10, (local.SqlStorageConfig.data_storage.count + 1))
      luns = [azurerm_virtual_machine_data_disk_attachment.data.lun]
    }

    log_settings {
      default_file_path = local.SqlStorageConfig.log_storage.default_file_path
      #luns              = (local.SqlStorageConfig.log_storage.count == "1") ? [10] : range(10, (local.SqlStorageConfig.log_storage.count + 1))
      luns = [azurerm_virtual_machine_data_disk_attachment.log.lun]
    }

    temp_db_settings {
      default_file_path = local.SqlStorageConfig.temp_db_storage.default_file_path
      luns              = local.SqlStorageConfig.temp_db_storage.luns
    }

  }

  dynamic "auto_backup" {
    for_each = var.enable_sql_auto_backup == false ? [] : [1]
    content {
      encryption_enabled = false
      #encryption_password = null
      retention_period_in_days        = 15
      storage_blob_endpoint           = ""
      storage_account_access_key      = ""
      system_databases_backup_enabled = true

      dynamic "manual_schedule" {
        for_each = var.enable_sql_auto_backup_manual == false ? [] : tolist(local.SqlServerConfig.sqlBackupConfigManualSchedule)
        content {
          full_backup_frequency           = manual_schedule.value.full_backup_frequency
          full_backup_start_hour          = manual_schedule.value.full_backup_start_hour
          full_backup_window_in_hours     = manual_schedule.value.full_backup_window_in_hours
          log_backup_frequency_in_minutes = manual_schedule.value.log_backup_frequency_in_minutes
        }
      }
    }
  }

  dynamic "auto_patching" {
    for_each = var.enable_sql_automate_patching == false ? [] : tomap([local.SqlServerConfig.sqlPatchingConfig])
    content {
      day_of_week                            = auto_patching.value.day_of_week
      maintenance_window_duration_in_minutes = auto_patching.value.maintenance_window_duration_in_minutes
      maintenance_window_starting_hour       = auto_patching.value.maintenance_window_starting_hour
    }
  }


}


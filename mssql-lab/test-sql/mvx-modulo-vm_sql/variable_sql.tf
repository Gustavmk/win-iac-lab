variable "sql_license_type" {
  description = "(Optional) The SQL Server license type. Possible values are AHUB (Azure Hybrid Benefit), DR (Disaster Recovery), and PAYG (Pay-As-You-Go). Changing this forces a new resource to be created."
  default     = "PAYG"
  type        = string
}

variable "r_services_enabled" {
  default = false
}
variable "enable_sql_automate_backup" {
  description = "(Optional) An auto_backup block as defined below. This block can be added to an existing resource, but removing this block forces a new resource to be created."
  default     = null
}

variable "enable_sql_automate_backup_manual" {
  description = "Define own backup schedule"
  default     = null
}

variable "enable_sql_automate_patching" {
  description = " (Optional) An auto_patching block as defined below."
  default     = false
}

locals {
  SqlServerConfig = {

    sqlpatchingConfig = {
      patchingEnabled               = var.enable_sql_automate_patching
      dayOfWeek                     = "Tuesday"
      maintenanceWindowDuration     = "120"
      maintenanceWindowStartingHour = "5"
    }

    sqlBackupConfigManualSchedule = {
      manualEnabled                   = var.enable_sql_automate_backup_manual
      full_backup_frequency           = "Weekly"
      full_backup_start_hour          = "23"
      full_backup_window_in_hours     = "7"
      log_backup_frequency_in_minutes = "15"
    }

  }
}


locals {
  disk_config = {
    dataDisk_count = ""
    logDisk_count  = ""
  }
}


locals {
  SqlStorageConfig = {
    disk_type             = ""
    storage_workload_type = ""

    data_storage = {
      default_file_path = "f:\\data"
      luns              = ""
    }

    log_storage = {
      default_file_path = "g:\\logs"
      luns              = ""

    }

    temp_db_storage = {
      default_file_path = "D:\\SQLTemp"
      luns              = [] // If you use an empty list ([]), it will pass through the validation and the tempdb will be created inside the temporary disk as desired.
    }
  }
}

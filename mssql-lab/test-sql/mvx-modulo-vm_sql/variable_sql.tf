variable "sql_login_username" {
}

variable "sql_login_password" {
}

variable "sql_connectivity_port" {
  default = 1433
  type    = number
}
variable "sql_connectivity_type" {
  type    = string
  default = "PRIVATE" // 
}
variable "sql_license_type" {
  description = "(Optional) The SQL Server license type. Possible values are AHUB (Azure Hybrid Benefit), DR (Disaster Recovery), and PAYG (Pay-As-You-Go). Changing this forces a new resource to be created."
  default     = "PAYG"
  type        = string
}

variable "r_services_enabled" {
  default = false
}

variable "enable_sql_key_vault_integration" {
  default = false
  type    = bool
}

variable "enable_sql_auto_backup" {
  description = "(Optional) An auto_backup block as defined below. This block can be added to an existing resource, but removing this block forces a new resource to be created."
  default     = false
  type        = bool
}

variable "enable_sql_auto_backup_manual" {
  description = "Define own backup schedule"
  default     = false
  type        = bool
}

variable "enable_sql_automate_patching" {
  description = " (Optional) An auto_patching block as defined below."
  default     = false
  type        = bool
}

locals {
  SqlServerConfig = {

    sqlPatchingConfig = {
      day_of_week                            = "Tuesday"
      maintenance_window_duration_in_minutes = "120"
      maintenance_window_starting_hour       = "5"
    }

    sqlBackupConfigManualSchedule = {
      full_backup_frequency           = "Weekly"
      full_backup_start_hour          = "23"
      full_backup_window_in_hours     = "7"
      log_backup_frequency_in_minutes = "15"
    }

  }
}

variable "disks_data_count" {
  default = "1"
}

variable "disks_log_count" {
  default = "1"
}

variable "sql_disk_type" {
  default = "NEW"
  type    = string
}
variable "sql_storage_workload_type" {
  default = "GENERAL"
  type    = string
}

locals {
  SqlStorageConfig = {

    data_storage = {
      default_file_path = "f:\\data"
      count             = var.disks_data_count
    }

    log_storage = {
      default_file_path = "g:\\logs"
      count             = var.disks_log_count

    }

    temp_db_storage = {
      default_file_path = "D:\\SQLTemp"
      luns              = [] // If you use an empty list ([]), it will pass through the validation and the tempdb will be created inside the temporary disk as desired.
    }
  }
}

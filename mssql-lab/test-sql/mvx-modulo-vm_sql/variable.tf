variable "vm_name" {
}

variable "size_name" {
}

variable "vm_adm_user" {
}

variable "vm_adm_password" {
  sensitive = true
}

variable "disk_size" {
  default = "128"
}

variable "sku_publisher" {
  default = "MicrosoftSQLServer"
}

variable "sku_offer" {
  default = "WindowsServer"
}

variable "sku_name" {
}

variable "sku_version" {
  default = "latest"
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
}
variable "vnet_name" {
}
variable "vnet_rg" {
}

variable "vnet_subnet" {
}

variable "join_ad_user" {
  default     = null
  description = "Account the computer to an existing AD"
  type        = string
}

variable "join_ad_password" {
  default     = null
  description = ""
  type        = string
  sensitive   = true
}

variable "join_ad_ou_path" {
  default     = null
  description = ""
  type        = string

}

variable "join_ad_domain_name" {
  default     = null
  description = ""
  type        = string
}

variable "enable_join_ad" {
  default = false
  type    = bool
}

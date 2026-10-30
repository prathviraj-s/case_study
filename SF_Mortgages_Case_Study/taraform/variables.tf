variable "snowflake_organization" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Terraform Snowflake user"
  type        = string
}

variable "snowflake_role" {
  description = "Role used by Terraform"
  type        = string
  default     = "SYSADMIN"
}

variable "database_name" {
  description = "Mortgage database"
  type        = string
  default     = "MY_DB"
}

variable "warehouse_name" {
  description = "Transformation warehouse"
  type        = string
  default     = "COMPUTE_WH"
}

variable "warehouse_size" {
  description = "Snowflake warehouse size"
  type        = string
  default     = "XSMALL"
}
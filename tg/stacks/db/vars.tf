variable "db_instance_type"		{ default = "db.t2.micro" }
variable "allocated_storage"	{ default = 8 }
variable "storage_type"       { default = "gp2" }
variable "provisioned_iops"   { default = 0 }
variable "mysql_major_version" { default = "5.6" }
variable "mysql_version"      { default = "5.6.41" }
variable "multi_az"           { default = "false" }
variable "db_admin_username"	{ }
variable "db_admin_password"	{ }
variable "db_backup_retention_period"	{ default = "30" }
variable "db_backup_window"		{ default = "05:00-06:00" }
variable "db_apply_immediately" { default = "false" }
variable "storage_encrypted"  { default = "false" }

variable "db_innodb_flush_log_at_trx_commit"  { default = "1" }

output "db_admin_user"		  { value = "${var.db_admin_username}" }
output "db_admin_password"	{ value = "${var.db_admin_password}" }

output "stack_db_present" { value = "true" }

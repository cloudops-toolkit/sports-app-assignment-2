variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain backups"
}

variable "preferred_backup_window" {
  type        = string
  default     = "03:00-04:00"
  description = "Daily time range during which backups happen"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "Mon:04:00-Mon:05:00"
  description = "Weekly time range during which system maintenance can occur"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "If the DB instance should have deletion protection enabled"
}
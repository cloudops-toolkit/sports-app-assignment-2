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

variable "db_cluster_identifier" {
  type = string
}

variable "secrets_manager_arn" {
  type = string
}

variable "rds_proxy_security_group_id" {
  type = string
}
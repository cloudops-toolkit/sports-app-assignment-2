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

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "rds_proxy_endpoint" {
  type = string
  description = "RDS Proxy endpoint"
}

variable "db_secret_arn" {
  type = string
  description = "ARN of the database credentials secret"
}

variable "db_cluster_endpoint" {
  type        = string
  description = "RDS cluster endpoint"
}
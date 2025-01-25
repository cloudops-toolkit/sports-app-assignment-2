variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "redis_cluster_id" {
  type = string
}

variable "alarm_topic_arns" {
  type = list(string)
  description = "List of SNS topic ARNs for alarm notifications."
}

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

variable "route_table_ids" {
  type = list(string)
  description = "List of private route table IDs"
}

variable "source_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs that need access to VPC endpoints (like ECS, Bastion)"
}
variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
  description = "Private subnet ID where bastion host will be launched"
}

variable "bastion_security_group_id" {
  type = string
}
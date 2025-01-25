variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "config" {
  description = "Configuration from config file"
  type = any
}
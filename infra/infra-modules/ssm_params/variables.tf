variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "redis_endpoint" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "session_secret" {
  type      = string
  sensitive = true
}

variable "encoding_key" {
  type      = string
  sensitive = true
}

variable "db_secret_arn" {
  type = string
}
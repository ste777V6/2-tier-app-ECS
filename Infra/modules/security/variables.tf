variable "name" {
  description = "Name prefix for the security groups"
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the security groups in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR, used to keep ALB->ECS and ECS->RDS traffic inside the VPC"
  type        = string
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 5000
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

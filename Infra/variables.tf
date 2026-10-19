#---general----

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  type    = string
}


variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string

}

variable "alb_log_bucket_name" {
  description = "Globally unique S3 bucket name for ALB access logs"
  type        = string
}





#Defualt tag moved under provider configuration
#variable "aws_tags" {
# description = "A map of tags to apply to all resources"
#type        = map(string)
#default = {
# Environment = "dev"
#Project     = "terraform-bootcamp"
#}
#}


#------------------------Networking variables---------------------------
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "The availability zones to use for the subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create a single NAT gateway so private subnets can reach the internet"
  type        = bool
  default     = true
}

variable "need_single_nat_gateway" {
  description = "Create a single NAT gateway so private subnets can reach the internet"
  type        = bool
}

# ---------------Security variables--------------------------

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


#---------------------Database variables-----------------------------



variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GiB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "myuser"
}

variable "multi_az" {
  description = "Run a standby in a second AZ (roughly doubles cost)"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Set to false for production."
  type        = bool
  default     = true
}

variable "secret_recovery_window_in_days" {
  description = "Days before a deleted secret is permanently removed. 0 = delete immediately (convenient for dev)."
  type        = number
  default     = 0
}


#--------------------ECS variables-----------------------------


variable "app_name" {
  description = "The name of the application"
  type        = string

}

variable "ecr_image" {
  description = "The ECR image to use for the ECS task"
  type        = string
  default     = "344707019777.dkr.ecr.us-east-1.amazonaws.com/bootcamp2026-student-portal-ecr:latest"
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
  default     = "stev6devops.2bd.net"
}


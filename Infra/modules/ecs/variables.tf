variable "name" {
  description = "Name prefix for the cluster, service, ECR repository, IAM roles and log group"
  type        = string
}

variable "container_name" {
  description = "Container name (also used as the task definition family)"
  type        = string
}

variable "image" {
  description = "Container image URI used for the initial task definition"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 5000
}

variable "cpu" {
  description = "Task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 512
}

variable "environment" {
  description = "Plain environment variables for the container (name => value)"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets injected as environment variables (name => Secrets Manager ARN)"
  type        = map(string)
  default     = {}
}

variable "execution_role_name" {
  description = "Name of the existing ECS task execution role"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "subnet_ids" {
  description = "Private subnets for the tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group the service registers tasks in"
  type        = string
}

variable "alb_resource_label" {
  description = "\"<alb arn_suffix>/<target group arn_suffix>\" for request-count autoscaling"
  type        = string
}

variable "desired_count" {
  description = "Initial number of tasks (autoscaling takes over after the first apply)"
  type        = number
  default     = 2
}

variable "autoscaling_min" {
  description = "Minimum number of tasks"
  type        = number
  default     = 2
}

variable "autoscaling_max" {
  description = "Maximum number of tasks"
  type        = number
  default     = 4
}

variable "cpu_target" {
  description = "Target average CPU utilisation (%)"
  type        = number
  default     = 70
}

variable "memory_target" {
  description = "Target average memory utilisation (%)"
  type        = number
  default     = 70
}

variable "requests_per_target" {
  description = "Target ALB requests per task"
  type        = number
  default     = 1000
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 7
}

variable "enable_container_insights" {
  description = "Enable Container Insights (extra cost, recommended for production)"
  type        = bool
  default     = false
}

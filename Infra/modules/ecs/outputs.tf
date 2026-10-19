output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "task_definition_family" {
  description = "Task definition family"
  value       = aws_ecs_task_definition.this.family
}

output "container_name" {
  description = "Container name in the task definition"
  value       = var.container_name
}

output "ecr_repository_url" {
  description = "ECR repository URL to push images to"
  value       = aws_ecr_repository.this.repository_url
}

output "log_group_name" {
  description = "CloudWatch log group for the containers"
  value       = aws_cloudwatch_log_group.this.name
}

output "execution_role_arn" {
  description = "ARN of the task execution role"
  value       = data.aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "ARN of the task role"
  value       = aws_iam_role.task.arn
}

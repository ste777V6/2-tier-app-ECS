# --- Networking -------------------------------------------------------------

output "vpc_id" {
  value = module.networking.vpc_id
}

output "nat_gateway_public_ips" {
  value = module.networking.nat_gateway_public_ips
}

# --- Load balancer ----------------------------------------------------------

output "load_balancer_dns_name" {
  description = "Point the app CNAME at your DNS provider to this"
  value       = module.alb.alb_dns_name
}

output "acm_validation_cname_name" {
  description = "Create this CNAME at the external DNS provider to validate the certificate"
  value       = module.alb.acm_validation_cname_name
}

output "acm_validation_cname_value" {
  value = module.alb.acm_validation_cname_value
}

output "target_group_names" {
  description = "Blue/green target groups (for the deployment pipeline)"
  value       = module.alb.target_group_names
}

# --- Application ------------------------------------------------------------

output "ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_task_definition_family" {
  value = module.ecs.task_definition_family
}

module "ecs" {
  source = "./modules/ecs"

  name               = var.name
  container_name     = var.app_name
  image              = var.ecr_image
  container_port     = var.app_port
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.security.ecs_sg_id]

  target_group_arn   = module.alb.blue_target_group_arn
  alb_resource_label = module.alb.blue_target_group_resource_label

  secrets = {
    DB_LINK = module.database.secret_arn
  }

  desired_count   = var.desired_count
  autoscaling_min = var.autoscaling_min
  autoscaling_max = var.autoscaling_max
}

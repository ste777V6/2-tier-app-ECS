module "alb" {
  source = "./modules/alb"

  # ALB and target group names are limited to 32 characters, so use the
  # short app name here instead of local.name
  name               = var.app_name
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  security_group_id  = module.security.alb_sg_id
  certificate_domain = "${var.app_name}.${var.domain_name}"
  log_bucket_name    = var.alb_log_bucket_name
  app_port           = var.app_port
}

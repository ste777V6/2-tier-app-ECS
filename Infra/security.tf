module "security" {
  source = "./modules/security"

  name     = var.name
  vpc_id   = module.networking.vpc_id
  vpc_cidr = var.vpc_cidr
  app_port = var.app_port
  db_port  = var.db_port

  depends_on = [module.networking]
}
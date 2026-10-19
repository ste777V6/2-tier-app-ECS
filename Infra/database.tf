module "database" {
  source = "./modules/database"

  name = var.name

  private_subnet_cidrs = var.private_subnet_cidrs

  security_group_ids = module.security.rds_sg_id

  engine_version = var.engine_version 

  instance_class = var.instance_class

  allocated_storage = var.allocated_storage

  db_name = var.db_name

  username = var.username

  multi_az = var.multi_az

  skip_final_snapshot = var.skip_final_snapshot

  secret_recovery_window_in_days = var.secret_recovery_window_in_days

}

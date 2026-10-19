terraform {
  backend "s3" {
    bucket       = "devops-projects-tf-states"
    key          = "3-tier-app-ECS/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
  }
}
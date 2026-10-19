terraform {
  backend "s3" {
    bucket       = "devops-projects-tf-states"
    key          = "3-tier-app-ECS/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
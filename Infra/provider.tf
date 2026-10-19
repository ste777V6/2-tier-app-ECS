terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {

    tags = {
      Environment = var.environment
      Project     = "terraform-bootcamp"
      ManagedBy   = "Terraform"
      Owner       = "Rapture"
      CostCenter  = "IT"
    }
  }

}
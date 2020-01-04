locals {
  staging_availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
}

terraform {
  backend "s3" {
    encrypt = "true"
    region = "ap-northeast-1"
    bucket = "terraform_ecs-tfstates"
    key = "terraform.tfstate"
    acl = "bucket-owner-full-control"
  }
}

provider "aws" {
  profile = "terraform_ecs"
  region = var.region
}

resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = file("${path.module}/staging_key.pub")
}

module "networking" {
  source               = "../modules/networking"
  environment          = "staging"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = var.region
  availability_zones   = local.staging_availability_zones
}

module "rds" {
  source            = "../modules/rds"
  environment       = "staging"
  allocated_storage = "20"
  database_name     = var.staging_database_name
  database_username = var.staging_database_username
  database_password = var.staging_database_password
  subnet_ids        = module.networking.private_subnets_id
  vpc_id            = module.networking.vpc_id
  instance_class    = "db.t2.micro"
}

module "ecs" {
  domain              = var.domain
  source              = "../modules/ecs"
  environment         = "staging"
  vpc_id              = module.networking.vpc_id
  availability_zones  = local.staging_availability_zones
  repository_name     = "terraform_ecs"
  repository_url      = var.repository_url
  repository_tag      = var.repository_tag
  subnets_ids         = module.networking.private_subnets_id
  public_subnet_ids   = module.networking.public_subnets_id
  security_groups_ids = [
    module.networking.security_groups_ids,
    module.rds.db_access_sg_id
  ]
  database_endpoint   = module.rds.rds_address
  database_name       = var.staging_database_name
  database_username   = var.staging_database_username
  database_password   = var.staging_database_password
  secret_key_base     = var.staging_secret_key_base
}

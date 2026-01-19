provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project     = "Portfolio"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  enable_https   = false
  domain_name    = ""
  hosted_zone_id = ""

  tags = {
    Project     = "terraform-asg-lb"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


module "asg" {
  source = "./modules/asg"

  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn

  tags = {
    Project     = "terraform-asg-alb"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

}

module "ecr" {
  source = "./modules/ecr"

  name = "portfolio-app"

  tags = {
    Project = "terraform-docker-asg"
  }
}


module "waf" {
  source = "./modules/waf"
}

#waf asso
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = module.alb.alb_arn
  web_acl_arn  = module.waf.web_acl_arn
}
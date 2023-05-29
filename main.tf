terraform {

 backend "s3" {
      bucket  = "tfmade-states-bucket"
      key = "states-infra/terraform.tfstate"
      region = "us-east-1"
      dynamodb_table = "DB-state-locking"
      encrypt = true
    }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
    }
  }
}
 provider "aws" {
   region = "us-east-1"
 }

 module "state-files" {
  source      = "./modules/state-files"
  bucket_name = "tfmade-states-bucket"
}
 
 module "vpc" {
  source = "./modules/vpc"
  
  #VPC Input Vars
  vpc_cidr = local.vpc_cidr
  availability_zones = local.availability_zones
  public_subnet_cidrs = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
 }
 module "database" {
   source = "./modules/database"
     #RDS Input Vars
  cloud_vpc_id          = module.vpc.cloud_vpc_id
  cloud_private_subnets = module.vpc.cloud_private_subnets
  cloud_private_subnet_cidrs = local.private_subnet_cidrs

  db_az = local.availability_zones[0]
  db_name = "clouddatabaseInstance"
  db_user_name = var.db_user_name
  db_user_password = var.db_user_password
 }

 module "webserver" {
   source = "./modules/webserver"
    #Web server (EC2 Instances) Input vars
  cloud_vpc_id =  module.vpc.cloud_vpc_id
  cloud_public_subnets = module.vpc.cloud_public_subnets
 }
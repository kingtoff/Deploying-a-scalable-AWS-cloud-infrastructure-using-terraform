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
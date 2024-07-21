terraform {
  required_version = ">=0.13.1"
  required_providers {
    aws = ">=3.54.0"
    local = ">=2.1.0"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "new-vpc" {
  source = "./modules/vpc"

  // Passe as variáveis e os valores que você está utilizando no vpc/main.tf
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
  source = "./modules/eks"

  // Passe as variáveis e os valores que você está utilizando no eks/main.tf
  prefix         = var.prefix
  cluster_name   = var.cluster_name
  retention_days = var.retention_days
  desired_size   = var.desired_size
  max_size       = var.max_size
  min_size       = var.min_size
  subnet_ids     = module.new-vpc.subnet_ids  // Precisamos pegar o subnet_ids do output em ./modules/vpc/outputs.tf
  vpc_id         = module.new-vpc.vpc_id      // Precisamos pegar o vpc_id do output em ./modules/vpc/outputs.tf
}
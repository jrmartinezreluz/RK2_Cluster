provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "ec2" {
  source = "./modules/ec2"

  key_name         = var.key_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.vpc.public_subnet_id
  vpc_id           = module.vpc.vpc_id
  aws_region       = var.aws_region
  ssh_ingress_cidr = var.ssh_ingress_cidr
}

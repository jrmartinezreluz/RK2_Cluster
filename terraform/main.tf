provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  availability_zone   = var.availability_zone
}

module "ec2" {
  source = "./modules/ec2"

  key_name           = var.key_name
  ami_id             = var.ami_id
  instance_master    = var.instance_master
  instance_workers   = var.instance_workers
  instance_micro     = var.instance_micro
  subnet_id          = module.vpc.public_subnet_id
  vpc_id             = module.vpc.vpc_id
  aws_region         = var.aws_region
  ssh_ingress_cidr   = var.ssh_ingress_cidr
}

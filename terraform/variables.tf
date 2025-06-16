variable "aws_region"         { default = "us-east-1" }
variable "vpc_cidr"           { default = "10.0.0.0/16" }
variable "public_subnet_cidr"{ default = "10.0.1.0/24" }
variable "key_name"           { default = "ark" }
variable "ami_id"             { default = "ami-0731becbf832f281e" } # Ubuntu 24.04
variable "instance_master"      { default = "r6i.large" }
variable "instance_workers"     { default = "t3.medium" }
variable "instance_micro"       { default = "r6i.large" }
variable "ssh_ingress_cidr"   { default = "0.0.0.0/0" } # Cámbialo a tu IP pública para mayor seguridad

variable "availability_zone" {
  description = "Availability Zone to deploy subnet and EC2 instances"
  default     = "us-east-1b"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet"
  type        = string
}

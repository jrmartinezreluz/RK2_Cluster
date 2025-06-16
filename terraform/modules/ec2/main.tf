resource "aws_security_group" "rke2_sg" {
  name        = "rke2-security-group"
  description = "Allow SSH, internal communication, and external access to LB"
  vpc_id      = var.vpc_id

  # SSH desde tu IP
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ssh_ingress_cidr]
  }

  # Comunicación total entre nodos
  ingress {
    description = "All traffic within security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Acceso a NGINX desde Internet
  ingress {
    description = "Kubernetes API via LB"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NGINX HTTP/HTTPS"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rke2-sg"
  }
}

locals {
  instances = [
    { name = "lb",        type = var.instance_micro },
    { name = "master1",   type = var.instance_master },
    { name = "master2",   type = var.instance_master },
    { name = "master3",   type = var.instance_master },
    { name = "worker1",   type = var.instance_workers },
    { name = "worker2",   type = var.instance_workers },
    { name = "rundeck",   type = var.instance_micro }
  ]
}

resource "aws_instance" "nodes" {
  for_each = { for inst in local.instances : inst.name => inst }

  ami                         = var.ami_id
  instance_type               = each.value.type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.rke2_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 150
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = each.key
    Role = each.key == "lb" ? "load-balancer" : startswith(each.key, "master") ? "master" : "worker"
  }
}

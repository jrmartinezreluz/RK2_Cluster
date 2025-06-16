output "lb_public_ip" {
  value = aws_instance.nodes["lb"].public_ip
}

output "masters_public_ips" {
  description = "Public IPs of the master nodes, mapped by name"
  value = {
    "master1" = aws_instance.nodes["master1"].public_ip
    "master2" = aws_instance.nodes["master2"].public_ip
    "master3" = aws_instance.nodes["master3"].public_ip
  }
}

 output "workers_public_ips" {
  description = "Public IPs of the worker nodes, mapped by name"
  value = {
    "worker1" = aws_instance.nodes["worker1"].public_ip
    "worker2" = aws_instance.nodes["worker2"].public_ip
  }
}

output "security_group_id" {
  description = "ID of the main RKE2 security group"
  value       = aws_security_group.rke2_sg.id
}

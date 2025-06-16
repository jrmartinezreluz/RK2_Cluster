output "lb_public_ip" {
  description = "Public IP of the load balancer"
  value       = module.ec2.lb_public_ip
}

output "masters_public_ips" {
  description = "Public IPs of the master nodes"
  value       = module.ec2.masters_public_ips
}

output "workers_public_ips" {
  description = "Public IPs of the worker nodes"
  value       = module.ec2.workers_public_ips
}

output "rke2_security_group_id" {
  description = "ID of the security group used by all nodes"
  value       = module.ec2.security_group_id
}

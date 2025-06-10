output "lb_public_ip" {
  value = module.ec2.lb_public_ip
}

output "masters_public_ips" {
  value = module.ec2.masters_public_ips
}

output "workers_public_ips" {
  value = module.ec2.workers_public_ips
}

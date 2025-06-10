output "lb_public_ip" {
  value = aws_instance.nodes["lb"].public_ip
}

output "masters_public_ips" {
  value = [
    aws_instance.nodes["master1"].public_ip,
    aws_instance.nodes["master2"].public_ip,
    aws_instance.nodes["master3"].public_ip
  ]
}

output "workers_public_ips" {
  value = [
    aws_instance.nodes["worker1"].public_ip,
    aws_instance.nodes["worker2"].public_ip
  ]
}

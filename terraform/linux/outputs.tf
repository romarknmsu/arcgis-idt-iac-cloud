output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.arcgis_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "portal_instance_ids" {
  description = "IDs of Portal instances"
  value       = aws_instance.arcgis_portal[*].id
}

output "portal_public_ips" {
  description = "Public IP addresses of Portal instances"
  value       = aws_instance.arcgis_portal[*].public_ip
}

output "server_instance_ids" {
  description = "IDs of Server instances"
  value       = aws_instance.arcgis_server[*].id
}

output "server_public_ips" {
  description = "Public IP addresses of Server instances"
  value       = aws_instance.arcgis_server[*].public_ip
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.arcgis_alb.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.arcgis_alb.arn
}

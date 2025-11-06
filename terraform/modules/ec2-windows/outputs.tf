output "instance_id" {
  description = "ID of the Windows EC2 instance"
  value       = aws_instance.windows.id
}

output "public_ip" {
  description = "Public IP address of the Windows instance"
  value       = aws_instance.windows.public_ip
}

output "private_ip" {
  description = "Private IP address of the Windows instance"
  value       = aws_instance.windows.private_ip
}

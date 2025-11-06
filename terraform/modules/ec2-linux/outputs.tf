output "instance_id" {
  description = "ID of the Linux EC2 instance"
  value       = aws_instance.linux.id
}

output "public_ip" {
  description = "Public IP address of the Linux instance"
  value       = aws_instance.linux.public_ip
}

output "private_ip" {
  description = "Private IP address of the Linux instance"
  value       = aws_instance.linux.private_ip
}

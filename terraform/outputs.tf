output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "linux_instance_id" {
  description = "ID of the Linux EC2 instance"
  value       = var.enable_linux ? module.ec2_linux[0].instance_id : null
}

output "linux_public_ip" {
  description = "Public IP of the Linux EC2 instance"
  value       = var.enable_linux ? module.ec2_linux[0].public_ip : null
}

output "windows_instance_id" {
  description = "ID of the Windows EC2 instance"
  value       = var.enable_windows ? module.ec2_windows[0].instance_id : null
}

output "windows_public_ip" {
  description = "Public IP of the Windows EC2 instance"
  value       = var.enable_windows ? module.ec2_windows[0].public_ip : null
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_endpoint : null
}

output "s3_bucket_name" {
  description = "S3 bucket name for ArcGIS builds"
  value       = var.s3_bucket_name
}

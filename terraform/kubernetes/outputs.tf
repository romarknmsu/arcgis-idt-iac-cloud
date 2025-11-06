output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.arcgis_cluster.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.arcgis_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.arcgis_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.arcgis_cluster.certificate_authority[0].data
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.arcgis_nodes.id
}

output "arcgis_namespace" {
  description = "Kubernetes namespace for ArcGIS Enterprise"
  value       = kubernetes_namespace.arcgis.metadata[0].name
}

output "kubectl_config" {
  description = "kubectl config command"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.arcgis_cluster.name}"
}

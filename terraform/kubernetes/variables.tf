variable "environment" {
  description = "Deployment environment (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Kubernetes cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
  default     = "m5.2xlarge"
}

variable "desired_node_count" {
  description = "Desired number of Kubernetes nodes"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of Kubernetes nodes"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of Kubernetes nodes"
  type        = number
  default     = 6
}

variable "node_disk_size" {
  description = "Disk size for Kubernetes nodes (GB)"
  type        = number
  default     = 100
}

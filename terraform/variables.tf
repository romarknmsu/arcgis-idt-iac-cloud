variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., daily-build, dev, prod)"
  type        = string
  default     = "daily-build"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "arcgis-enterprise"
}

variable "s3_bucket_name" {
  description = "S3 bucket containing ArcGIS daily builds"
  type        = string
}

variable "arcgis_version" {
  description = "ArcGIS Enterprise version to deploy"
  type        = string
  default     = "11.2"
}

variable "linux_instance_type" {
  description = "EC2 instance type for Linux servers"
  type        = string
  default     = "t3.xlarge"
}

variable "windows_instance_type" {
  description = "EC2 instance type for Windows servers"
  type        = string
  default     = "t3.xlarge"
}

variable "eks_node_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "t3.large"
}

variable "eks_node_count" {
  description = "Number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "key_pair_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the infrastructure"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_linux" {
  description = "Enable Linux EC2 deployment"
  type        = bool
  default     = true
}

variable "enable_windows" {
  description = "Enable Windows EC2 deployment"
  type        = bool
  default     = true
}

variable "enable_eks" {
  description = "Enable EKS cluster deployment"
  type        = bool
  default     = true
}

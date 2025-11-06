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
  default     = "10.0.0.0/16"
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access ArcGIS Enterprise"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "linux_ami_id" {
  description = "AMI ID for Linux instances (Ubuntu 22.04 LTS recommended)"
  type        = string
  default     = "" # Will use latest Ubuntu 22.04 if not specified
}

variable "ssh_key_name" {
  description = "Name of SSH key pair for EC2 instances"
  type        = string
  default     = ""
}

variable "portal_instance_count" {
  description = "Number of Portal instances"
  type        = number
  default     = 1
}

variable "portal_instance_type" {
  description = "EC2 instance type for Portal"
  type        = string
  default     = "m5.xlarge"
}

variable "portal_root_volume_size" {
  description = "Root volume size for Portal instances (GB)"
  type        = number
  default     = 100
}

variable "server_instance_count" {
  description = "Number of Server instances"
  type        = number
  default     = 2
}

variable "server_instance_type" {
  description = "EC2 instance type for Server"
  type        = string
  default     = "m5.xlarge"
}

variable "server_root_volume_size" {
  description = "Root volume size for Server instances (GB)"
  type        = number
  default     = 100
}

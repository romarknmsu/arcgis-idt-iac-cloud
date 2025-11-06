# ArcGIS Enterprise on Kubernetes Infrastructure

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "arcgis-terraform-state"
  #   key            = "kubernetes/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "ArcGIS-Enterprise"
      Platform    = "Kubernetes"
      ManagedBy   = "Terraform"
    }
  }
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "arcgis-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "arcgis-${var.environment}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node Group IAM Role
resource "aws_iam_role" "eks_node_role" {
  name = "arcgis-${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "arcgis-${var.environment}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# VPC for EKS
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                              = "arcgis-${var.environment}-eks-vpc"
    "kubernetes.io/cluster/arcgis-${var.environment}" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "arcgis-${var.environment}-eks-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.availability_zones_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                              = "arcgis-${var.environment}-eks-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/arcgis-${var.environment}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = var.availability_zones_count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                              = "arcgis-${var.environment}-eks-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/arcgis-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  }
}

# NAT Gateway for private subnets
resource "aws_eip" "nat_eip" {
  count  = var.availability_zones_count
  domain = "vpc"

  tags = {
    Name = "arcgis-${var.environment}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.availability_zones_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "arcgis-${var.environment}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.eks_igw]
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "arcgis-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  count  = var.availability_zones_count
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "arcgis-${var.environment}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "arcgis-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "arcgis-${var.environment}-eks-cluster-sg"
  }
}

resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.eks_cluster_sg.id
  description       = "Allow workstation to communicate with the cluster API Server"
}

# EKS Cluster
resource "aws_eks_cluster" "arcgis_cluster" {
  name     = "arcgis-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = {
    Name = "arcgis-${var.environment}-eks-cluster"
  }
}

# EKS Node Group
resource "aws_eks_node_group" "arcgis_nodes" {
  cluster_name    = aws_eks_cluster.arcgis_cluster.name
  node_group_name = "arcgis-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.desired_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
  }

  update_config {
    max_unavailable = 1
  }

  disk_size = var.node_disk_size

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = {
    Name = "arcgis-${var.environment}-eks-node-group"
  }

  labels = {
    environment = var.environment
    workload    = "arcgis"
  }
}

# Data source for available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = aws_eks_cluster.arcgis_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.arcgis_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.arcgis_cluster.name
    ]
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.arcgis_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.arcgis_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.arcgis_cluster.name
      ]
    }
  }
}

# Namespace for ArcGIS Enterprise
resource "kubernetes_namespace" "arcgis" {
  metadata {
    name = "arcgis-enterprise"
    labels = {
      name        = "arcgis-enterprise"
      environment = var.environment
    }
  }

  depends_on = [aws_eks_cluster.arcgis_cluster]
}

# Storage Class for ArcGIS
resource "kubernetes_storage_class" "arcgis_storage" {
  metadata {
    name = "arcgis-storage"
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_cluster.arcgis_cluster]
}

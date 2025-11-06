# VPC and Networking Module
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}

# IAM Role for EC2 instances to access S3
resource "aws_iam_role" "ec2_s3_access" {
  name = "${var.project_name}-${var.environment}-ec2-s3-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "${var.project_name}-${var.environment}-s3-access"
  role = aws_iam_role.ec2_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_s3_access.name
}

# Security Group for ArcGIS Enterprise
resource "aws_security_group" "arcgis_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ArcGIS Enterprise"
  vpc_id      = module.networking.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # ArcGIS Server ports
  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Portal ports
  ingress {
    from_port   = 7080
    to_port     = 7080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 7443
    to_port     = 7443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-sg"
  }
}

# Linux EC2 Instance
module "ec2_linux" {
  count  = var.enable_linux ? 1 : 0
  source = "./modules/ec2-linux"

  project_name         = var.project_name
  environment          = var.environment
  instance_type        = var.linux_instance_type
  subnet_id            = module.networking.public_subnet_ids[0]
  security_group_id    = aws_security_group.arcgis_sg.id
  key_pair_name        = var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  s3_bucket_name       = var.s3_bucket_name
  arcgis_version       = var.arcgis_version
}

# Windows EC2 Instance
module "ec2_windows" {
  count  = var.enable_windows ? 1 : 0
  source = "./modules/ec2-windows"

  project_name         = var.project_name
  environment          = var.environment
  instance_type        = var.windows_instance_type
  subnet_id            = module.networking.public_subnet_ids[0]
  security_group_id    = aws_security_group.arcgis_sg.id
  key_pair_name        = var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  s3_bucket_name       = var.s3_bucket_name
  arcgis_version       = var.arcgis_version
}

# EKS Cluster
module "eks" {
  count  = var.enable_eks ? 1 : 0
  source = "./modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  node_instance_type = var.eks_node_instance_type
  node_count         = var.eks_node_count
  s3_bucket_name     = var.s3_bucket_name
}

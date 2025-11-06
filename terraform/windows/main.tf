# ArcGIS Enterprise on Windows Infrastructure

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "arcgis-terraform-state"
  #   key            = "windows/terraform.tfstate"
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
      Platform    = "Windows"
      ManagedBy   = "Terraform"
    }
  }
}

# VPC for ArcGIS Enterprise
resource "aws_vpc" "arcgis_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "arcgis-${var.environment}-windows-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "arcgis_igw" {
  vpc_id = aws_vpc.arcgis_vpc.id

  tags = {
    Name = "arcgis-${var.environment}-windows-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = var.availability_zones_count
  vpc_id                  = aws_vpc.arcgis_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "arcgis-${var.environment}-windows-public-subnet-${count.index + 1}"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = var.availability_zones_count
  vpc_id            = aws_vpc.arcgis_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "arcgis-${var.environment}-windows-private-subnet-${count.index + 1}"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.arcgis_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arcgis_igw.id
  }

  tags = {
    Name = "arcgis-${var.environment}-windows-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rta" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for ArcGIS Server on Windows
resource "aws_security_group" "arcgis_windows_sg" {
  name        = "arcgis-${var.environment}-windows-sg"
  description = "Security group for ArcGIS Enterprise on Windows"
  vpc_id      = aws_vpc.arcgis_vpc.id

  # RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "RDP access"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS access"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTP access"
  }

  # ArcGIS Server default ports
  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "ArcGIS Server HTTP"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "ArcGIS Server HTTPS"
  }

  # Portal for ArcGIS ports
  ingress {
    from_port   = 7080
    to_port     = 7080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Portal HTTP"
  }

  ingress {
    from_port   = 7443
    to_port     = 7443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Portal HTTPS"
  }

  # WinRM for remote management
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "WinRM"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "arcgis-${var.environment}-windows-sg"
  }
}

# EC2 Instance for ArcGIS Portal on Windows
resource "aws_instance" "arcgis_portal" {
  count         = var.portal_instance_count
  ami           = var.windows_ami_id
  instance_type = var.portal_instance_type
  subnet_id     = aws_subnet.public_subnet[count.index % var.availability_zones_count].id

  vpc_security_group_ids = [aws_security_group.arcgis_windows_sg.id]
  key_name               = var.ssh_key_name

  root_block_device {
    volume_size = var.portal_root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/scripts/portal-setup.ps1", {
    environment = var.environment
  })

  tags = {
    Name = "arcgis-${var.environment}-windows-portal-${count.index + 1}"
    Role = "Portal"
    OS   = "Windows"
  }
}

# EC2 Instance for ArcGIS Server on Windows
resource "aws_instance" "arcgis_server" {
  count         = var.server_instance_count
  ami           = var.windows_ami_id
  instance_type = var.server_instance_type
  subnet_id     = aws_subnet.public_subnet[count.index % var.availability_zones_count].id

  vpc_security_group_ids = [aws_security_group.arcgis_windows_sg.id]
  key_name               = var.ssh_key_name

  root_block_device {
    volume_size = var.server_root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/scripts/server-setup.ps1", {
    environment = var.environment
  })

  tags = {
    Name = "arcgis-${var.environment}-windows-server-${count.index + 1}"
    Role = "Server"
    OS   = "Windows"
  }
}

# Application Load Balancer
resource "aws_lb" "arcgis_alb" {
  name               = "arcgis-${var.environment}-win-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.arcgis_windows_sg.id]
  subnets            = aws_subnet.public_subnet[*].id

  enable_deletion_protection = var.environment == "production" ? true : false

  tags = {
    Name = "arcgis-${var.environment}-windows-alb"
  }
}

# Target Group for Portal
resource "aws_lb_target_group" "portal_tg" {
  name     = "arcgis-${var.environment}-win-portal-tg"
  port     = 7443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.arcgis_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/arcgis/home"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "arcgis-${var.environment}-windows-portal-tg"
  }
}

# Target Group Attachment for Portal
resource "aws_lb_target_group_attachment" "portal_tga" {
  count            = var.portal_instance_count
  target_group_arn = aws_lb_target_group.portal_tg.arn
  target_id        = aws_instance.arcgis_portal[count.index].id
  port             = 7443
}

# Data source for available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

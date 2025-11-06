# ArcGIS Enterprise Infrastructure as Code

This repository contains Infrastructure as Code (IaC) for deploying ArcGIS Enterprise on multiple platforms using Terraform and GitHub Actions.

## Overview

This project provides automated deployment of ArcGIS Enterprise infrastructure across three platforms:
- **Linux** (Ubuntu on AWS EC2)
- **Windows** (Windows Server on AWS EC2)
- **Kubernetes** (AWS EKS)

## Architecture

### Linux Deployment
- ArcGIS Portal on Ubuntu 22.04 LTS
- ArcGIS Server on Ubuntu 22.04 LTS
- Application Load Balancer for high availability
- VPC with public and private subnets

### Windows Deployment
- ArcGIS Portal on Windows Server 2022
- ArcGIS Server on Windows Server 2022
- Application Load Balancer for high availability
- VPC with public and private subnets

### Kubernetes Deployment
- AWS EKS cluster with multiple node groups
- ArcGIS Portal and Server deployed as containers
- Auto-scaling capabilities
- Persistent storage for data
- Ingress controller for external access

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **GitHub Repository Secrets** configured:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (optional, defaults to us-east-1)
3. **Terraform** >= 1.0 (installed automatically by GitHub Actions)
4. **ArcGIS Enterprise License** (required for actual deployment)

## Getting Started

### 1. Configure GitHub Environments

Create environments in your GitHub repository:
- `dev` - Development environment
- `staging` - Staging environment
- `production` - Production environment

### 2. Set Required Secrets

In your GitHub repository, go to Settings > Secrets and variables > Actions, and add:

```
AWS_ACCESS_KEY_ID=<your-aws-access-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-key>
AWS_REGION=us-east-1  # Optional
```

### 3. Run the Workflow

1. Go to the **Actions** tab in your GitHub repository
2. Select **Deploy ArcGIS Enterprise Infrastructure**
3. Click **Run workflow**
4. Choose your parameters:
   - **Environment**: dev, staging, or production
   - **Platform**: all, linux, windows, or kubernetes
   - **Action**: plan, apply, or destroy
   - **Terraform Version**: (optional, defaults to 1.6.0)
5. Click **Run workflow**

## Workflow Options

### Environment
- `dev` - Development environment with minimal resources
- `staging` - Staging environment for testing
- `production` - Production environment with high availability

### Platform
- `all` - Deploy all platforms (Linux, Windows, Kubernetes)
- `linux` - Deploy only Linux infrastructure
- `windows` - Deploy only Windows infrastructure
- `kubernetes` - Deploy only Kubernetes infrastructure

### Action
- `plan` - Generate and show Terraform execution plan
- `apply` - Apply the Terraform configuration
- `destroy` - Destroy the infrastructure

## Directory Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy-arcgis-enterprise.yml  # Main deployment workflow
├── terraform/
│   ├── linux/                            # Linux infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── scripts/
│   │       ├── portal-setup.sh
│   │       └── server-setup.sh
│   ├── windows/                          # Windows infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── scripts/
│   │       ├── portal-setup.ps1
│   │       └── server-setup.ps1
│   └── kubernetes/                       # Kubernetes infrastructure
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── manifests/
│           └── arcgis-deployment.yaml
└── README.md
```

## Terraform Modules

### Linux Module (`terraform/linux/`)
Deploys ArcGIS Enterprise on Ubuntu Linux instances with:
- VPC with public and private subnets
- EC2 instances for Portal and Server
- Security groups with appropriate ports
- Application Load Balancer
- Setup scripts for system preparation

### Windows Module (`terraform/windows/`)
Deploys ArcGIS Enterprise on Windows Server instances with:
- VPC with public and private subnets
- EC2 instances for Portal and Server
- Security groups with RDP and ArcGIS ports
- Application Load Balancer
- PowerShell scripts for system preparation

### Kubernetes Module (`terraform/kubernetes/`)
Deploys ArcGIS Enterprise on AWS EKS with:
- EKS cluster with managed node groups
- VPC with public and private subnets
- NAT gateways for private subnet internet access
- Kubernetes namespace for ArcGIS
- Storage class for persistent volumes
- Deployment manifests for Portal and Server

## Customization

### Variables

Each platform has its own `variables.tf` file where you can customize:
- Instance types
- Number of instances
- Storage sizes
- Network configuration
- Security settings

**Important Security Note**: By default, `allowed_cidr_blocks` is set to `0.0.0.0/0` for ease of initial setup. For production deployments, **always restrict this to your specific IP ranges or networks**. Example:

```hcl
allowed_cidr_blocks = ["10.0.0.0/8", "203.0.113.0/24"]
```

### Backend Configuration

For production use, uncomment and configure the S3 backend in each `main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "platform/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

## Post-Deployment Steps

After infrastructure is deployed:

### Linux/Windows
1. SSH/RDP into the instances
2. Download ArcGIS Enterprise installation files
3. Run the installation wizards
4. Configure Portal and Server
5. Apply your ArcGIS license

### Kubernetes
1. Configure kubectl: `aws eks update-kubeconfig --region <region> --name arcgis-<environment>`
2. Apply Kubernetes manifests: `kubectl apply -f terraform/kubernetes/manifests/`
3. Wait for pods to be ready: `kubectl get pods -n arcgis-enterprise`
4. Access services via LoadBalancer endpoints

## Monitoring and Logs

### GitHub Actions
- View workflow runs in the Actions tab
- Download artifacts for Terraform state files
- Check deployment summary for status

### AWS Resources
- CloudWatch for logs and metrics
- EC2 Console for instance status
- EKS Console for cluster health

## Security Considerations

1. **Secrets Management**: Never commit credentials to the repository
2. **Network Security**: Configure `allowed_cidr_blocks` appropriately
3. **Encryption**: All volumes are encrypted by default
4. **IAM Roles**: Use least privilege principle
5. **Updates**: Keep Terraform and provider versions updated

## Troubleshooting

### Terraform Validation Fails
- Check that all required variables are set
- Ensure AWS credentials are valid
- Verify AMI IDs are available in your region

### Deployment Timeout
- Increase instance types if resources are insufficient
- Check AWS service quotas
- Review CloudWatch logs for errors

### Kubernetes Pods Not Starting
- Check pod logs: `kubectl logs -n arcgis-enterprise <pod-name>`
- Verify storage class is available
- Ensure node group has sufficient resources

## Cost Estimation

Approximate monthly costs (us-east-1):
- **Linux**: ~$300-500 (2x m5.xlarge instances + networking)
- **Windows**: ~$500-800 (2x m5.2xlarge instances + licensing + networking)
- **Kubernetes**: ~$400-700 (EKS cluster + 3x m5.2xlarge nodes + networking)

Note: Costs vary by region, instance types, and usage patterns.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Open an issue in this repository
- Refer to [ArcGIS Enterprise documentation](https://enterprise.arcgis.com/)
- Contact Esri Support for ArcGIS-specific issues

## Acknowledgments

- Built with Terraform and GitHub Actions
- Designed for AWS infrastructure
- Based on ArcGIS Enterprise best practices

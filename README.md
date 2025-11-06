# ArcGIS Enterprise IaC Cloud

Infrastructure as Code (IaC) solution for automating daily deployments of ArcGIS Enterprise on AWS using Terraform, Ansible, and GitHub Actions.

## Overview

This repository provides a complete CI/CD pipeline for deploying and tearing down ArcGIS Enterprise environments on AWS. It supports:

- **Linux EC2 instances** (Amazon Linux 2)
- **Windows EC2 instances** (Windows Server 2022)
- **Amazon EKS** (Kubernetes) clusters
- **Automated daily builds** from AWS S3
- **Full ArcGIS Enterprise installation** including Portal, Server, Data Store, Web Adaptor, and Mission Server
- **Infrastructure as Code** with Terraform
- **Configuration Management** with Ansible
- **CI/CD Pipeline** with GitHub Actions

## Architecture

The solution deploys:

1. **VPC with public and private subnets** across multiple availability zones
2. **EC2 instances** for Linux and Windows ArcGIS Enterprise deployments
3. **EKS cluster** for containerized ArcGIS Enterprise deployments
4. **IAM roles and policies** for secure S3 access
5. **Security groups** with appropriate firewall rules
6. **Self-signed SSL certificates** for secure communications

## Prerequisites

### AWS Account Setup

1. AWS account with appropriate permissions
2. S3 bucket containing ArcGIS Enterprise daily builds
3. EC2 key pair for SSH access
4. S3 bucket for Terraform state storage

### Required Secrets

Configure the following secrets in your GitHub repository:

| Secret Name | Description |
|------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for deployment |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for deployment |
| `AWS_SSH_PRIVATE_KEY` | Private SSH key for EC2 access |
| `AWS_KEY_PAIR_NAME` | Name of the AWS EC2 key pair |
| `ARCGIS_S3_BUCKET` | S3 bucket containing ArcGIS builds |
| `ARCGIS_VERSION` | ArcGIS Enterprise version (e.g., "11.2") |
| `TERRAFORM_STATE_BUCKET` | S3 bucket for Terraform state |
| `WINDOWS_ADMIN_PASSWORD` | Administrator password for Windows instances |

## Project Structure

```
.
├── terraform/                  # Terraform infrastructure code
│   ├── main.tf                # Provider and backend configuration
│   ├── variables.tf           # Input variables
│   ├── resources.tf           # Main resources
│   ├── outputs.tf             # Output values
│   └── modules/
│       ├── networking/        # VPC, subnets, routing
│       ├── ec2-linux/         # Linux EC2 instances
│       ├── ec2-windows/       # Windows EC2 instances
│       └── eks/               # EKS cluster configuration
│
├── ansible/                   # Ansible configuration management
│   ├── ansible.cfg            # Ansible configuration
│   ├── playbook-linux.yml     # Linux configuration playbook
│   ├── playbook-windows.yml   # Windows configuration playbook
│   ├── inventories/           # Dynamic inventory
│   └── roles/
│       ├── common/            # Common configuration tasks
│       ├── linux-prerequisites/  # Linux prerequisites
│       ├── windows-prerequisites/ # Windows prerequisites
│       ├── certificates/      # SSL certificate management
│       └── arcgis-install/    # ArcGIS installation from S3
│
└── .github/
    └── workflows/
        ├── daily-deploy.yml   # Daily deployment workflow
        └── teardown.yml       # Environment teardown workflow
```

## Workflows

### Daily Deployment (`daily-deploy.yml`)

Runs automatically every weekday at 6:00 AM UTC or can be triggered manually.

**Steps:**
1. Deploy AWS infrastructure using Terraform
2. Wait for instances to initialize
3. Configure Linux servers with Ansible
4. Configure Windows servers with Ansible
5. Configure EKS cluster with kubectl
6. Notify completion status

**Manual Trigger:**
```bash
# Via GitHub UI: Actions → Daily ArcGIS Enterprise Deployment → Run workflow
# Select which components to deploy (Linux, Windows, EKS)
```

### Teardown (`teardown.yml`)

Runs automatically every weekday at 8:00 PM UTC or can be triggered manually.

**Steps:**
1. Confirm destruction (manual triggers require typing "destroy")
2. Run Terraform destroy to remove all resources
3. Verify cleanup completion

**Manual Trigger:**
```bash
# Via GitHub UI: Actions → Teardown Daily Build → Run workflow
# Type "destroy" to confirm
```

## Local Development

### Prerequisites

- Terraform >= 1.0
- Ansible >= 2.15
- AWS CLI configured
- Python 3.11+

### Terraform Deployment

```bash
cd terraform

# Initialize Terraform
terraform init \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="key=arcgis-enterprise/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Plan deployment
terraform plan \
  -var="s3_bucket_name=YOUR_ARCGIS_BUCKET" \
  -var="key_pair_name=YOUR_KEY_PAIR"

# Apply changes
terraform apply
```

### Ansible Configuration

```bash
cd ansible

# Update inventory with your instance IPs
vim inventories/hosts.yml

# Run Linux playbook
ansible-playbook -i inventories/hosts.yml playbook-linux.yml

# Run Windows playbook
ansible-playbook -i inventories/hosts.yml playbook-windows.yml
```

## Configuration

### Terraform Variables

Key variables in `terraform/variables.tf`:

- `aws_region`: AWS region for deployment (default: us-east-1)
- `environment`: Environment name (default: daily-build)
- `s3_bucket_name`: S3 bucket with ArcGIS builds (required)
- `arcgis_version`: ArcGIS Enterprise version (default: 11.2)
- `linux_instance_type`: EC2 instance type for Linux (default: t3.xlarge)
- `windows_instance_type`: EC2 instance type for Windows (default: t3.xlarge)
- `eks_node_instance_type`: Instance type for EKS nodes (default: t3.large)
- `enable_linux`: Enable Linux EC2 deployment (default: true)
- `enable_windows`: Enable Windows EC2 deployment (default: true)
- `enable_eks`: Enable EKS cluster deployment (default: true)

### Ansible Variables

Key variables in Ansible roles:

- `arcgis_version`: ArcGIS Enterprise version
- `s3_bucket_name`: S3 bucket containing builds
- `arcgis_s3_prefix`: S3 prefix for ArcGIS files

## S3 Bucket Structure

Expected S3 structure for ArcGIS builds:

```
s3://your-arcgis-bucket/
└── arcgis-enterprise/
    └── 11.2/
        ├── ArcGIS_Server_Linux.tar.gz
        ├── Portal_for_ArcGIS_Linux.tar.gz
        ├── ArcGIS_DataStore_Linux.tar.gz
        ├── ArcGIS_Web_Adaptor_Linux.tar.gz
        ├── Mission_Server_Linux.tar.gz
        ├── ArcGIS_Server_Windows.exe
        ├── Portal_for_ArcGIS_Windows.exe
        ├── ArcGIS_DataStore_Windows.exe
        ├── ArcGIS_Web_Adaptor_Windows.exe
        └── Mission_Server_Windows.exe
```

## Security Considerations

1. **Secrets Management**: All sensitive data stored as GitHub secrets
2. **IAM Roles**: Instances use IAM roles for S3 access (no credentials on instances)
3. **Encryption**: EBS volumes encrypted at rest
4. **Network Security**: Security groups restrict access to necessary ports
5. **SSL Certificates**: Self-signed certificates generated for each deployment
6. **Private Subnets**: EKS nodes deployed in private subnets with NAT gateway access

## Monitoring and Logging

- **Terraform State**: Stored in S3 with versioning enabled
- **Ansible Logs**: Available in GitHub Actions workflow logs
- **Linux Logs**: `/var/log/arcgis-install/init.log`
- **Windows Logs**: `C:\ArcGIS\Logs\init.log`
- **Deployment Artifacts**: Stored in GitHub Actions artifacts

## Troubleshooting

### Common Issues

**Issue**: Terraform apply fails with authentication error
- **Solution**: Verify AWS credentials in GitHub secrets

**Issue**: Ansible playbook fails to connect to Windows
- **Solution**: Ensure Windows instance has WinRM enabled (user-data script handles this)

**Issue**: ArcGIS installers not found in S3
- **Solution**: Verify S3 bucket structure matches expected format

**Issue**: EKS cluster creation times out
- **Solution**: Check AWS service quotas for VPC and EKS resources

### Debug Mode

Enable verbose logging:

```bash
# Terraform
export TF_LOG=DEBUG

# Ansible
ansible-playbook -vvv playbook-linux.yml
```

## Cost Optimization

- Resources are automatically torn down daily to minimize costs
- Use appropriate instance sizes for your workload
- Enable EBS volume termination on instance deletion
- Monitor AWS Cost Explorer for unexpected charges

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally before committing
5. Submit a pull request

## License

This project is provided as-is for use with ArcGIS Enterprise deployments.

## Support

For issues and questions:
- Check the GitHub Issues page
- Review workflow logs in GitHub Actions
- Consult ArcGIS Enterprise documentation

## Roadmap

- [ ] Add support for ArcGIS Data Store
- [ ] Implement blue-green deployment strategy
- [ ] Add CloudWatch monitoring and alerting
- [ ] Support for multiple ArcGIS versions simultaneously
- [ ] Automated testing of ArcGIS installations
- [ ] Integration with corporate SSO
- [ ] Backup and restore procedures

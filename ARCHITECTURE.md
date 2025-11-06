# Architecture Overview

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Actions                          │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   Daily      │  │   Teardown   │  │   Manual     │        │
│  │   Deploy     │  │   Workflow   │  │   Triggers   │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                  │                  │                 │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                               │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                      │  │
│  │                                                            │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐       │  │
│  │  │  Public Subnet      │  │  Public Subnet      │       │  │
│  │  │  10.0.1.0/24        │  │  10.0.2.0/24        │       │  │
│  │  │  (AZ-A)             │  │  (AZ-B)             │       │  │
│  │  │                     │  │                     │       │  │
│  │  │  ┌──────────────┐   │  │  ┌──────────────┐  │       │  │
│  │  │  │   Linux EC2  │   │  │  │ Windows EC2  │  │       │  │
│  │  │  │   ArcGIS     │   │  │  │   ArcGIS     │  │       │  │
│  │  │  │   Server     │   │  │  │   Server     │  │       │  │
│  │  │  └──────────────┘   │  │  └──────────────┘  │       │  │
│  │  └─────────────────────┘  └─────────────────────┘       │  │
│  │                                                            │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐       │  │
│  │  │  Private Subnet     │  │  Private Subnet     │       │  │
│  │  │  10.0.10.0/24       │  │  10.0.11.0/24       │       │  │
│  │  │  (AZ-A)             │  │  (AZ-B)             │       │  │
│  │  │                     │  │                     │       │  │
│  │  │  ┌──────────────┐   │  │  ┌──────────────┐  │       │  │
│  │  │  │  EKS Worker  │   │  │  │  EKS Worker  │  │       │  │
│  │  │  │    Node      │   │  │  │    Node      │  │       │  │
│  │  │  └──────────────┘   │  │  └──────────────┘  │       │  │
│  │  └─────────────────────┘  └─────────────────────┘       │  │
│  │                                                            │  │
│  │  ┌──────────────┐                                         │  │
│  │  │  Internet    │                                         │  │
│  │  │  Gateway     │                                         │  │
│  │  └──────────────┘                                         │  │
│  │                                                            │  │
│  │  ┌──────────────┐  ┌──────────────┐                      │  │
│  │  │  NAT Gateway │  │  NAT Gateway │                      │  │
│  │  │  (AZ-A)      │  │  (AZ-B)      │                      │  │
│  │  └──────────────┘  └──────────────┘                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    EKS Control Plane                      │  │
│  │              (Managed by AWS)                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    S3 Buckets                             │  │
│  │                                                            │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐       │  │
│  │  │  ArcGIS Builds      │  │  Terraform State    │       │  │
│  │  │  Bucket             │  │  Bucket             │       │  │
│  │  └─────────────────────┘  └─────────────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    IAM Roles                              │  │
│  │                                                            │  │
│  │  • EC2 Instance Role (S3 Read Access)                    │  │
│  │  • EKS Cluster Role                                       │  │
│  │  • EKS Node Group Role                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. GitHub Actions Workflows

**Daily Deploy Workflow**
- Triggers: Scheduled (6 AM UTC weekdays) or manual
- Steps:
  1. Checkout code
  2. Configure AWS credentials
  3. Deploy infrastructure with Terraform
  4. Configure Linux servers with Ansible
  5. Configure Windows servers with Ansible
  6. Setup EKS cluster
  7. Notify completion

**Teardown Workflow**
- Triggers: Scheduled (8 PM UTC weekdays) or manual
- Steps:
  1. Checkout code
  2. Configure AWS credentials
  3. Destroy infrastructure with Terraform
  4. Verify cleanup

### 2. Terraform Modules

**Networking Module**
- VPC with CIDR 10.0.0.0/16
- 2 Public subnets across 2 AZs
- 2 Private subnets across 2 AZs
- Internet Gateway for public subnets
- NAT Gateways for private subnets
- Route tables and associations

**EC2 Linux Module**
- Amazon Linux 2 AMI
- Instance type: t3.xlarge (configurable)
- 100GB encrypted EBS volume
- User data script for initialization
- IAM instance profile for S3 access

**EC2 Windows Module**
- Windows Server 2022 AMI
- Instance type: t3.xlarge (configurable)
- 150GB encrypted EBS volume
- User data script for initialization
- WinRM enabled for Ansible

**EKS Module**
- Kubernetes version 1.28
- Managed node group
- 3 worker nodes (configurable)
- Instance type: t3.large (configurable)
- Deployed in private subnets

### 3. Ansible Roles

**Common Role**
- System updates
- Base package installation
- Timezone configuration
- NTP setup

**Linux Prerequisites Role**
- Java installation
- Python dependencies
- File system limits
- Kernel parameters
- User creation
- Directory setup

**Windows Prerequisites Role**
- .NET Framework installation
- IIS setup
- Visual C++ redistributables
- User creation
- Directory setup

**Certificates Role**
- Self-signed certificate generation
- Certificate installation
- Key management

**ArcGIS Install Role**
- Download installers from S3
- Extract archives
- Prepare for installation
- Logging

### 4. Security

**Network Security**
- Security groups with specific port rules
- SSH (22) for Linux
- RDP (3389) for Windows
- WinRM (5985) for Ansible
- ArcGIS ports (80, 443, 6080, 6443, 7080, 7443)

**IAM Security**
- Role-based access to S3
- No credentials on instances
- Least privilege principle

**Data Security**
- EBS encryption at rest
- Secure credential management via GitHub Secrets
- SSL/TLS for communications

## Data Flow

### Deployment Flow

```
1. GitHub Actions triggers workflow
                ↓
2. Terraform provisions AWS infrastructure
                ↓
3. EC2 instances start with user-data scripts
                ↓
4. User-data installs prerequisites
                ↓
5. Ansible connects to instances
                ↓
6. Ansible configures instances
                ↓
7. Ansible downloads ArcGIS from S3
                ↓
8. ArcGIS ready for installation
```

### Daily Build Access Flow

```
1. ArcGIS daily builds uploaded to S3
                ↓
2. Workflow triggers at scheduled time
                ↓
3. Infrastructure deployed
                ↓
4. Instances use IAM role to access S3
                ↓
5. Daily builds downloaded to instances
                ↓
6. Ready for testing/deployment
```

## Scalability Considerations

- **Horizontal Scaling**: Add more EC2 instances via Terraform variables
- **Vertical Scaling**: Increase instance types in variables
- **Multi-Region**: Deploy to multiple regions by duplicating configuration
- **Load Balancing**: Add ALB/NLB in front of ArcGIS servers

## Cost Optimization

- Automatic teardown prevents overnight charges
- Use Spot instances for non-production (future enhancement)
- Right-size instances based on actual usage
- Delete old Terraform state versions
- Clean up unused S3 objects

## Disaster Recovery

- Terraform state stored in S3 with versioning
- Infrastructure code in Git
- Daily builds backed up in S3
- Quick redeployment via workflow

## Monitoring Points

- GitHub Actions workflow status
- AWS CloudWatch metrics (future)
- Terraform state changes
- Ansible execution logs
- ArcGIS application logs

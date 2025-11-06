# Setup Guide

This guide will walk you through setting up the ArcGIS Enterprise daily build deployment system.

## Step 1: AWS Account Preparation

### Create S3 Buckets

1. **Terraform State Bucket**
```bash
aws s3 mb s3://your-terraform-state-bucket
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

2. **ArcGIS Builds Bucket**
```bash
aws s3 mb s3://your-arcgis-builds-bucket
```

### Create EC2 Key Pair

```bash
aws ec2 create-key-pair \
  --key-name arcgis-enterprise-key \
  --query 'KeyMaterial' \
  --output text > arcgis-enterprise-key.pem
chmod 400 arcgis-enterprise-key.pem
```

### Upload ArcGIS Builds to S3

Organize your ArcGIS builds in S3:

```bash
# Linux installers
aws s3 cp ArcGIS_Server_Linux.tar.gz \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp Portal_for_ArcGIS_Linux.tar.gz \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp ArcGIS_DataStore_Linux.tar.gz \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp ArcGIS_Web_Adaptor_Linux.tar.gz \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp Mission_Server_Linux.tar.gz \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

# Windows installers
aws s3 cp ArcGIS_Server_Windows.exe \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp Portal_for_ArcGIS_Windows.exe \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp ArcGIS_DataStore_Windows.exe \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp ArcGIS_Web_Adaptor_Windows.exe \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp Mission_Server_Windows.exe \
  s3://your-arcgis-builds-bucket/arcgis-enterprise/11.2/
```

## Step 2: GitHub Repository Setup

### Fork or Clone Repository

```bash
git clone https://github.com/romarknmsu/arcgis-idt-iac-cloud.git
cd arcgis-idt-iac-cloud
```

### Configure GitHub Secrets

Navigate to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:

1. **AWS_ACCESS_KEY_ID**
   - Your AWS access key ID with permissions for EC2, EKS, S3, IAM

2. **AWS_SECRET_ACCESS_KEY**
   - Your AWS secret access key

3. **AWS_SSH_PRIVATE_KEY**
   - Content of your private key file (arcgis-enterprise-key.pem)
   ```bash
   cat arcgis-enterprise-key.pem
   # Copy the entire output including BEGIN and END lines
   ```

4. **AWS_KEY_PAIR_NAME**
   - Name of your EC2 key pair (e.g., "arcgis-enterprise-key")

5. **ARCGIS_S3_BUCKET**
   - Name of your S3 bucket containing builds (e.g., "your-arcgis-builds-bucket")

6. **ARCGIS_VERSION**
   - ArcGIS Enterprise version (e.g., "11.2")

7. **TERRAFORM_STATE_BUCKET**
   - Name of your Terraform state bucket (e.g., "your-terraform-state-bucket")

8. **WINDOWS_ADMIN_PASSWORD**
   - Strong password for Windows Administrator account
   - Must meet Windows complexity requirements

## Step 3: Verify Configuration

### Test Terraform Locally

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vim terraform.tfvars

# Initialize
terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=arcgis-enterprise/test/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Plan
terraform plan

# If plan looks good, you're ready!
```

### Test Ansible Locally

```bash
cd ansible

# Install Ansible
pip install ansible boto3 botocore

# Verify configuration
ansible-config dump --only-changed
```

## Step 4: First Deployment

### Manual Workflow Trigger

1. Go to GitHub Actions in your repository
2. Select "Daily ArcGIS Enterprise Deployment"
3. Click "Run workflow"
4. Choose which components to deploy:
   - Enable Linux: ✓
   - Enable Windows: ✓
   - Enable EKS: ✓
5. Click "Run workflow"

### Monitor Deployment

1. Watch the workflow execution in GitHub Actions
2. Check each job's logs for progress
3. Deployment typically takes 30-45 minutes

### Verify Deployment

After successful deployment:

1. Check the deployment artifacts for IP addresses
2. SSH to Linux instance:
   ```bash
   ssh -i arcgis-enterprise-key.pem ec2-user@<LINUX_IP>
   ```

3. RDP to Windows instance (use Administrator and your password)

4. Verify EKS cluster:
   ```bash
   aws eks update-kubeconfig --name arcgis-enterprise-daily-build-eks
   kubectl get nodes
   ```

## Step 5: Configure Scheduled Runs

The workflows are already configured to run automatically:

- **Deployment**: Every weekday at 6:00 AM UTC
- **Teardown**: Every weekday at 8:00 PM UTC

To modify the schedule, edit the cron expressions in:
- `.github/workflows/daily-deploy.yml`
- `.github/workflows/teardown.yml`

Example: To run at 7:00 AM EST (12:00 PM UTC):
```yaml
schedule:
  - cron: '0 12 * * 1-5'
```

## Step 6: Customization

### Adjust Instance Sizes

Edit `terraform/variables.tf` default values:

```hcl
variable "linux_instance_type" {
  default = "t3.2xlarge"  # Increase for more resources
}
```

### Add Additional Roles

Create new Ansible roles:

```bash
cd ansible/roles
mkdir my-custom-role
cd my-custom-role
mkdir tasks handlers defaults
```

### Modify Network Configuration

Edit `terraform/resources.tf` to adjust VPC, subnets, or security groups.

## Step 7: Monitoring and Maintenance

### Check Workflow Runs

- Go to GitHub Actions tab
- Review recent workflow runs
- Check for any failures

### Monitor AWS Costs

```bash
# Install AWS CLI cost explorer
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE
```

### Review Logs

- **GitHub Actions**: Full workflow logs
- **Linux**: `/var/log/arcgis-install/init.log`
- **Windows**: `C:\ArcGIS\Logs\init.log`

## Troubleshooting

### Workflow Fails to Start

- Verify GitHub secrets are configured
- Check AWS credentials are valid
- Ensure repository has Actions enabled

### Terraform Apply Fails

- Check AWS service quotas
- Verify IAM permissions
- Review Terraform state bucket access

### Ansible Connection Issues

- Verify security groups allow SSH (22) and WinRM (5985)
- Check instance user-data completed successfully
- Ensure SSH key matches the key pair used

### Cost Concerns

- Verify teardown workflow is running
- Check for orphaned resources in AWS console
- Use AWS Cost Anomaly Detection

## Next Steps

1. Customize the deployment for your specific needs
2. Add monitoring and alerting
3. Implement backup procedures
4. Configure ArcGIS Enterprise post-installation
5. Set up load balancers and DNS

## Support

For issues:
1. Check GitHub Issues
2. Review workflow logs
3. Consult AWS CloudWatch
4. Review Terraform and Ansible documentation

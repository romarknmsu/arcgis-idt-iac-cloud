# Quick Start Guide

Get up and running with ArcGIS Enterprise daily builds in 15 minutes!

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] AWS account with admin access
- [ ] GitHub account with repository access
- [ ] ArcGIS Enterprise installers ready to upload
- [ ] 15 minutes of setup time

## 5-Step Quick Setup

### Step 1: Prepare AWS (5 minutes)

```bash
# Create Terraform state bucket
aws s3 mb s3://my-terraform-state-bucket

# Create ArcGIS builds bucket
aws s3 mb s3://my-arcgis-builds-bucket

# Create EC2 key pair and save it
aws ec2 create-key-pair --key-name arcgis-key \
  --query 'KeyMaterial' --output text > arcgis-key.pem
chmod 400 arcgis-key.pem
```

### Step 2: Upload ArcGIS Builds (5 minutes)

Upload your daily builds to S3 in this structure:

```bash
aws s3 cp ArcGIS_Server_Linux.tar.gz \
  s3://my-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp Portal_for_ArcGIS_Linux.tar.gz \
  s3://my-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp ArcGIS_Server_Windows.exe \
  s3://my-arcgis-builds-bucket/arcgis-enterprise/11.2/

aws s3 cp Portal_for_ArcGIS_Windows.exe \
  s3://my-arcgis-builds-bucket/arcgis-enterprise/11.2/
```

### Step 3: Configure GitHub Secrets (3 minutes)

In your GitHub repository, go to **Settings → Secrets → Actions** and add:

| Secret Name | Value |
|------------|--------|
| AWS_ACCESS_KEY_ID | Your AWS access key |
| AWS_SECRET_ACCESS_KEY | Your AWS secret key |
| AWS_SSH_PRIVATE_KEY | Content of arcgis-key.pem |
| AWS_KEY_PAIR_NAME | arcgis-key |
| ARCGIS_S3_BUCKET | my-arcgis-builds-bucket |
| ARCGIS_VERSION | 11.2 |
| TERRAFORM_STATE_BUCKET | my-terraform-state-bucket |
| WINDOWS_ADMIN_PASSWORD | SecurePassword123! |

### Step 4: Run First Deployment (2 minutes)

1. Go to **Actions** tab in your repository
2. Select **"Daily ArcGIS Enterprise Deployment"**
3. Click **"Run workflow"**
4. Keep all defaults checked (Linux, Windows, EKS)
5. Click **"Run workflow"**

⏱️ The deployment takes about 30-40 minutes to complete.

### Step 5: Verify Deployment (5 minutes)

After the workflow completes:

1. Download the **deployment-info** artifact from the workflow run
2. Find your instance IP addresses in `info.txt`
3. Connect to your instances:

```bash
# Linux
ssh -i arcgis-key.pem ec2-user@<LINUX_IP>

# Windows (use RDP client)
# Connect to <WINDOWS_IP> with Administrator/<YOUR_PASSWORD>
```

## Daily Operations

### Automatic Schedule

By default, the workflows run:
- **Deploy**: 6:00 AM UTC (weekdays)
- **Teardown**: 8:00 PM UTC (weekdays)

### Manual Operations

**Deploy on demand:**
1. Actions → Daily ArcGIS Enterprise Deployment → Run workflow

**Teardown on demand:**
1. Actions → Teardown Daily Build → Run workflow
2. Type "destroy" to confirm

## What Gets Deployed

Your daily build environment includes:

✅ **Linux EC2 Instance**
- Amazon Linux 2
- Java 11, Python, AWS CLI pre-installed
- ArcGIS Server and Portal installers downloaded
- Self-signed SSL certificate

✅ **Windows EC2 Instance**
- Windows Server 2022
- .NET Framework, IIS, Visual C++ installed
- ArcGIS Server and Portal installers downloaded
- Self-signed SSL certificate

✅ **EKS Cluster**
- Kubernetes 1.28
- 3 worker nodes
- Ready for ArcGIS Enterprise on Kubernetes

✅ **Networking**
- Isolated VPC
- Public and private subnets
- Internet and NAT gateways
- Security groups with proper rules

✅ **Security**
- IAM roles for S3 access
- Encrypted EBS volumes
- No hardcoded credentials

## Costs

Typical daily costs (deployed for 14 hours):

| Resource | Cost/day |
|----------|----------|
| 2x EC2 t3.xlarge | ~$8 |
| EKS Cluster | ~$5 |
| NAT Gateways | ~$3 |
| **Total** | **~$16/day** |

💡 **Cost Tip**: Disable EKS if not needed to save ~$5/day

## Customization

### Change Instance Sizes

Edit `terraform/variables.tf`:

```hcl
variable "linux_instance_type" {
  default = "t3.2xlarge"  # Upgrade from t3.xlarge
}
```

### Change Schedule

Edit `.github/workflows/daily-deploy.yml`:

```yaml
schedule:
  - cron: '0 12 * * 1-5'  # 7 AM EST = 12 PM UTC
```

### Disable Components

When running manually, uncheck components you don't need:
- [ ] Enable Linux
- [ ] Enable Windows
- [ ] Enable EKS

## Troubleshooting

### Workflow fails immediately
- Check GitHub Secrets are configured correctly
- Verify AWS credentials have proper permissions

### Terraform fails
- Check AWS service quotas (VPCs, Elastic IPs, etc.)
- Verify S3 buckets exist and are accessible

### Ansible fails to connect
- Wait 5 minutes after Terraform completes for instances to initialize
- Check security groups allow SSH (22) and WinRM (5985)

### High costs
- Verify teardown workflow is running
- Check for orphaned resources in AWS console
- Consider reducing instance sizes

## Getting Help

1. **Check Logs**: Go to Actions → Select workflow run → View logs
2. **Check Documentation**: See README.md and SETUP.md for details
3. **GitHub Issues**: Report problems in the Issues tab
4. **AWS CloudWatch**: Check for infrastructure issues

## Next Steps

After your first successful deployment:

1. ✅ Complete ArcGIS Enterprise installation
2. ✅ Configure ArcGIS Portal and Server
3. ✅ Set up federation
4. ✅ Test your applications
5. ✅ Customize workflows for your needs

## FAQ

**Q: Can I deploy to multiple regions?**
A: Yes, create separate environments by modifying the region variable.

**Q: Can I keep the environment running overnight?**
A: Yes, disable the teardown workflow or adjust the schedule.

**Q: Does this work with other ArcGIS versions?**
A: Yes, change the ARCGIS_VERSION secret and upload the correct installers.

**Q: Can I use this for production?**
A: This is designed for daily builds/testing. For production, implement additional security, monitoring, and backup procedures.

**Q: How do I update the infrastructure?**
A: Modify the Terraform files, commit, and run the deployment workflow.

## Support

For detailed documentation:
- 📖 **README.md**: Complete overview
- 🏗️ **ARCHITECTURE.md**: Technical architecture
- 🛠️ **SETUP.md**: Detailed setup instructions

Happy deploying! 🚀

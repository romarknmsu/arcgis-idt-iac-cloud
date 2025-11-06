data "aws_ami" "windows_server" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "windows" {
  ami                    = data.aws_ami.windows_server.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = 150
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.ps1", {
    s3_bucket_name = var.s3_bucket_name
    arcgis_version = var.arcgis_version
    project_name   = var.project_name
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-windows"
    OS   = "Windows"
  }
}

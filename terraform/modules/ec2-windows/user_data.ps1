<powershell>
# Set error action preference
$ErrorActionPreference = "Continue"

# Create log directory
New-Item -ItemType Directory -Force -Path C:\ArcGIS\Logs

# Start logging
Start-Transcript -Path C:\ArcGIS\Logs\init.log -Append

Write-Host "Starting Windows instance initialization..."

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install prerequisites
choco install -y `
    python3 `
    awscli `
    7zip `
    git `
    openssh

# Install .NET Framework 4.8 (required for ArcGIS)
choco install -y netfx-4.8

# Create directories
New-Item -ItemType Directory -Force -Path C:\ArcGIS\Installer
New-Item -ItemType Directory -Force -Path C:\ArcGIS\Software
New-Item -ItemType Directory -Force -Path C:\ArcGIS\Certificates

# Set environment variables
[System.Environment]::SetEnvironmentVariable("ARCGIS_VERSION", "${arcgis_version}", "Machine")
[System.Environment]::SetEnvironmentVariable("S3_BUCKET", "${s3_bucket_name}", "Machine")
[System.Environment]::SetEnvironmentVariable("PROJECT_NAME", "${project_name}", "Machine")

# Enable Windows Remote Management for Ansible
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Configure firewall for WinRM
New-NetFirewallRule -Name "WinRM-HTTP" -DisplayName "Windows Remote Management (HTTP-In)" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
New-NetFirewallRule -Name "WinRM-HTTPS" -DisplayName "Windows Remote Management (HTTPS-In)" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

Write-Host "Windows instance initialization complete"
Stop-Transcript

# Create marker file
New-Item -ItemType File -Force -Path C:\ArcGIS\init-complete.txt
</powershell>

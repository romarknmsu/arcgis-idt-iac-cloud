<powershell>
# ArcGIS Portal Setup Script for Windows
# This script prepares the Windows instance for ArcGIS Portal installation

$ErrorActionPreference = "Stop"
$Environment = "${environment}"

# Create log file
$LogFile = "C:\arcgis-setup.log"
Start-Transcript -Path $LogFile

Write-Host "Starting ArcGIS Portal setup for environment: $Environment"

# Install Windows Features
Write-Host "Installing Windows Features..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-WebSockets
Install-WindowsFeature -Name Web-Asp-Net45

# Create ArcGIS directories
Write-Host "Creating ArcGIS directories..."
New-Item -ItemType Directory -Force -Path "C:\arcgis\portal"
New-Item -ItemType Directory -Force -Path "C:\arcgisportal"

# Set environment variables
Write-Host "Setting environment variables..."
[Environment]::SetEnvironmentVariable("ARCGIS_ENVIRONMENT", $Environment, "Machine")

# Configure Windows Firewall
Write-Host "Configuring Windows Firewall..."
New-NetFirewallRule -DisplayName "ArcGIS Portal HTTPS" -Direction Inbound -LocalPort 7443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "ArcGIS Portal HTTP" -Direction Inbound -LocalPort 7080 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow

# Disable IE Enhanced Security Configuration
Write-Host "Disabling IE Enhanced Security Configuration..."
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

# Set timezone
Write-Host "Setting timezone to UTC..."
Set-TimeZone -Id "UTC"

# Disable Windows Defender for better performance (optional)
Write-Host "Configuring Windows Defender..."
Set-MpPreference -DisableRealtimeMonitoring $true

# Enable Remote Desktop
Write-Host "Enabling Remote Desktop..."
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Set power plan to High Performance
Write-Host "Setting power plan to High Performance..."
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Configure page file
Write-Host "Configuring page file..."
$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
$ComputerSystem.AutomaticManagedPagefile = $false
$ComputerSystem.Put()
$PageFile = Get-WmiObject -Class Win32_PageFileSetting
$PageFile.InitialSize = 8192
$PageFile.MaximumSize = 16384
$PageFile.Put()

Write-Host "ArcGIS Portal preparation completed!"
Write-Host "Environment: $Environment"
Write-Host "Next steps:"
Write-Host "1. Download ArcGIS Portal installation files"
Write-Host "2. Run the Portal installation wizard"
Write-Host "3. Configure Portal with your organization settings"

Stop-Transcript
</powershell>

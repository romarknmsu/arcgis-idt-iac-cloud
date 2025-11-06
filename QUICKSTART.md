# Quick Start Guide - ArcGIS Enterprise Prerequisites

This guide will help you quickly set up ArcGIS Enterprise prerequisites on your servers.

## Prerequisites

1. **Install Ansible** on your control machine:
   ```bash
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install ansible python3-pip
   
   # On RHEL/CentOS
   sudo yum install ansible python3-pip
   
   # On macOS
   brew install ansible
   
   # Or using pip
   pip3 install ansible
   ```

2. **Clone this repository**:
   ```bash
   git clone https://github.com/romarknmsu/arcgis-idt-iac-cloud.git
   cd arcgis-idt-iac-cloud
   ```

3. **Install required Ansible collections**:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

## For Linux Servers

### Step 1: Configure Inventory

Edit `inventory/linux.yml` and add your server details:

```yaml
all:
  children:
    linux:
      hosts:
        arcgis-server1:
          ansible_host: 192.168.1.100
          ansible_user: root
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Step 2: Test Connectivity

```bash
ansible linux -i inventory/linux.yml -m ping
```

### Step 3: Run the Playbook

```bash
ansible-playbook -i inventory/linux.yml configure_linux_prerequisites.yml
```

### What It Does

- ✅ Verifies system requirements (RAM, disk space)
- ✅ Installs required packages (openssl, glibc, X11 libraries, etc.)
- ✅ Creates ArcGIS user and group
- ✅ Configures system limits and kernel parameters
- ✅ Configures firewall rules
- ✅ Disables SELinux (RHEL/CentOS)
- ✅ Creates installation directory

## For Windows Servers

### Step 1: Enable WinRM on Windows Server

Run this PowerShell script on your Windows server as Administrator:

```powershell
# Enable WinRM
Enable-PSRemoting -Force

# Allow unencrypted traffic (testing only)
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Configure basic authentication
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true

# Open firewall
New-NetFirewallRule -Name "WinRM-HTTP" -DisplayName "Windows Remote Management (HTTP-In)" `
  -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5985
```

### Step 2: Configure Inventory

Edit `inventory/windows.yml` and add your server details:

```yaml
all:
  children:
    windows:
      hosts:
        arcgis-win-server1:
          ansible_host: 192.168.1.200
          ansible_user: Administrator
          ansible_password: "YourPassword"
          ansible_connection: winrm
          ansible_port: 5985
```

**Security Note**: For production, use Ansible Vault to encrypt passwords:

```bash
ansible-vault create group_vars/all/vault.yml
```

Add to vault.yml:
```yaml
windows_admin_password: "YourPassword"
```

Then in inventory:
```yaml
ansible_password: "{{ windows_admin_password }}"
```

### Step 3: Test Connectivity

```bash
ansible windows -i inventory/windows.yml -m win_ping
```

### Step 4: Run the Playbook

```bash
ansible-playbook -i inventory/windows.yml configure_windows_prerequisites.yml

# If using vault:
ansible-playbook -i inventory/windows.yml configure_windows_prerequisites.yml --ask-vault-pass
```

### What It Does

- ✅ Verifies system requirements (RAM, disk space)
- ✅ Installs Microsoft Visual C++ Redistributable
- ✅ Installs .NET 8 Framework
- ✅ Installs and configures IIS
- ✅ Configures Windows Firewall rules
- ✅ Sets power plan to High Performance
- ✅ Creates installation directory
- ✅ Reboots if necessary

## Verify Installation

### Linux
```bash
# SSH to your server
ssh user@your-server

# Check ArcGIS user
id arcgis

# Check system limits
su - arcgis -c 'ulimit -a'

# Check kernel parameters
sysctl vm.max_map_count vm.swappiness net.ipv4.ip_local_port_range

# Check firewall rules
sudo firewall-cmd --list-all  # RHEL/CentOS
sudo ufw status               # Ubuntu
```

### Windows
```powershell
# RDP or WinRM to your server

# Check IIS
Get-Service W3SVC

# Check installed software
Get-Package | Where-Object { $_.Name -like "*Visual C++*" -or $_.Name -like "*.NET*" }

# Check firewall rules
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*ArcGIS*" }

# Check power plan
powercfg /list
```

## Next Steps

After running the prerequisites playbook:

1. **Download ArcGIS Enterprise** from My Esri portal
2. **Transfer installers** to the installation directory:
   - Linux: `/opt/arcgis/`
   - Windows: `C:\Program Files\ArcGIS\`
3. **Install ArcGIS components** in this order:
   - ArcGIS Server
   - Portal for ArcGIS
   - ArcGIS Data Store
   - ArcGIS Web Adaptor
4. **Configure your deployment** using ArcGIS Enterprise setup wizard

## Troubleshooting

### Linux: Permission Denied
```bash
# Make sure your user has sudo access
sudo -v

# Or specify become password
ansible-playbook -i inventory/linux.yml configure_linux_prerequisites.yml --ask-become-pass
```

### Windows: WinRM Authentication Failed
```powershell
# On Windows server, check WinRM configuration
winrm get winrm/config

# Enable basic auth if needed
winrm set winrm/config/service/auth @{Basic="true"}
```

### Connection Timeout
```bash
# Increase timeout in ansible.cfg
timeout = 60

# Or specify on command line
ansible-playbook -i inventory/linux.yml configure_linux_prerequisites.yml -e "ansible_timeout=60"
```

## Support

- Check the [main README](README.md) for detailed documentation
- Review [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Open an issue for bugs or feature requests

## Security Reminders

- 🔐 Always use Ansible Vault for passwords in production
- 🔐 Use SSH keys instead of passwords for Linux
- 🔐 Use HTTPS WinRM (port 5986) for Windows in production
- 🔐 Regularly update Ansible and collections
- 🔐 Review and audit firewall rules for your environment

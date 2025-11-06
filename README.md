# ArcGIS Enterprise - Infrastructure as Code

Infrastructure as Code (IaC) for deploying ArcGIS Enterprise using Ansible. This repository contains Ansible playbooks and roles to automatically configure all prerequisites and requirements for ArcGIS Enterprise on both Windows and Linux servers.

## Overview

This project provides automated configuration management for:
- **Windows Server**: Configure IIS, .NET Framework, Visual C++ Redistributables, and system settings
- **Linux Server**: Configure system packages, kernel parameters, user accounts, and firewall rules

## Prerequisites

### Control Node Requirements
The machine running Ansible needs:
- Ansible 2.15 or higher
- Python 3.8 or higher
- Required Ansible collections (see Installation)

### Target Node Requirements

#### Windows Servers
- Windows Server 2016, 2019, 2022, or 2025 (Standard or Datacenter with Desktop Experience)
- WinRM configured and accessible
- PowerShell 5.1 or higher
- Administrative access

#### Linux Servers
- RHEL/CentOS 7/8/9, Ubuntu 20.04/22.04, or SLES 12/15
- SSH access with sudo privileges
- Python 3.x installed

## Installation

1. Clone this repository:
```bash
git clone https://github.com/romarknmsu/arcgis-idt-iac-cloud.git
cd arcgis-idt-iac-cloud
```

2. Install required Ansible collections:
```bash
ansible-galaxy collection install -r requirements.yml
```

3. Configure your inventory files:
   - Edit `inventory/windows.yml` for Windows servers
   - Edit `inventory/linux.yml` for Linux servers

## Project Structure

```
.
├── ansible.cfg                          # Ansible configuration
├── requirements.yml                     # Required Ansible collections
├── configure_windows_prerequisites.yml  # Windows playbook
├── configure_linux_prerequisites.yml    # Linux playbook
├── inventory/                           # Inventory files
│   ├── windows.yml                      # Windows hosts inventory
│   └── linux.yml                        # Linux hosts inventory
├── group_vars/                          # Group variables
│   └── all/
│       └── main.yml                     # Global variables
└── roles/                               # Ansible roles
    ├── arcgis_prerequisites_windows/    # Windows prerequisites role
    │   ├── defaults/
    │   │   └── main.yml                 # Default variables
    │   └── tasks/
    │       └── main.yml                 # Windows tasks
    └── arcgis_prerequisites_linux/      # Linux prerequisites role
        ├── defaults/
        │   └── main.yml                 # Default variables
        └── tasks/
            └── main.yml                 # Linux tasks
```

## Usage

### Configure Windows Servers

1. Edit `inventory/windows.yml` with your server details
2. Run the playbook:
```bash
ansible-playbook -i inventory/windows.yml configure_windows_prerequisites.yml
```

### Configure Linux Servers

1. Edit `inventory/linux.yml` with your server details
2. Run the playbook:
```bash
ansible-playbook -i inventory/linux.yml configure_linux_prerequisites.yml
```

### Check Syntax Before Running
```bash
# Check Windows playbook
ansible-playbook --syntax-check configure_windows_prerequisites.yml

# Check Linux playbook
ansible-playbook --syntax-check configure_linux_prerequisites.yml
```

### Dry Run (Check Mode)
```bash
# Windows
ansible-playbook -i inventory/windows.yml configure_windows_prerequisites.yml --check

# Linux
ansible-playbook -i inventory/linux.yml configure_linux_prerequisites.yml --check
```

## What Gets Configured

### Windows Prerequisites

The Windows role configures:
- ✅ System requirements verification (RAM, disk space)
- ✅ Microsoft Visual C++ 2015-2022 Redistributable (x64)
- ✅ .NET 8 Framework
- ✅ IIS (Internet Information Services) with required features
- ✅ IIS application pool settings optimization
- ✅ Windows Firewall rules for ArcGIS ports (6080, 6443, 7080, 7443)
- ✅ Power plan set to High Performance
- ✅ Server Manager auto-launch disabled
- ✅ ArcGIS installation directory creation
- ✅ Automatic reboot if required

### Linux Prerequisites

The Linux role configures:
- ✅ System requirements verification (RAM, disk space)
- ✅ Required system packages (OpenSSL, glibc, X11 libraries, etc.)
- ✅ ArcGIS service account and group creation
- ✅ System limits configuration (file descriptors, processes)
- ✅ Kernel parameter tuning (vm.max_map_count, swappiness, port range)
- ✅ Firewall rules (firewalld on RHEL/CentOS, UFW on Ubuntu)
- ✅ SELinux disabled (RHEL/CentOS)
- ✅ Timezone set to UTC
- ✅ ArcGIS installation directory creation
- ✅ Automatic reboot if required

## Port Configuration

The following ports are configured for ArcGIS Enterprise:

| Port | Protocol | Component | Description |
|------|----------|-----------|-------------|
| 6080 | TCP | ArcGIS Server | HTTP |
| 6443 | TCP | ArcGIS Server | HTTPS |
| 7080 | TCP | Portal for ArcGIS | HTTP |
| 7443 | TCP | Portal for ArcGIS | HTTPS |
| 2443 | TCP | ArcGIS Data Store | HTTPS (Linux only) |
| 9876 | TCP | ArcGIS Data Store | Internal (Linux only) |

## Customization

### Modifying Variables

You can customize the configuration by overriding variables:

1. **Global variables**: Edit `group_vars/all/main.yml`
2. **Windows-specific**: Edit `roles/arcgis_prerequisites_windows/defaults/main.yml`
3. **Linux-specific**: Edit `roles/arcgis_prerequisites_linux/defaults/main.yml`
4. **Host-specific**: Add variables directly in inventory files

### Example: Change Installation Directory

In your inventory file:
```yaml
arcgis-server1:
  ansible_host: 192.168.1.100
  arcgis_install_dir: "/custom/path/arcgis"  # Linux
  # or
  arcgis_install_dir: "D:\\ArcGIS"           # Windows
```

## Security Best Practices

1. **Use Ansible Vault** for sensitive data:
```bash
ansible-vault create group_vars/all/vault.yml
```

2. **Store credentials securely**:
```yaml
# In vault.yml (encrypted)
windows_admin_password: "SecurePassword123!"
linux_root_password: "SecurePassword456!"
```

3. **Use the vault in playbooks**:
```bash
ansible-playbook -i inventory/windows.yml configure_windows_prerequisites.yml --ask-vault-pass
```

## Windows WinRM Setup

For Windows servers, WinRM must be configured. Run this PowerShell script on Windows servers:

```powershell
# Enable WinRM
Enable-PSRemoting -Force

# Allow unencrypted traffic (for testing only, use HTTPS in production)
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Configure basic authentication
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true

# Set up firewall rule
New-NetFirewallRule -Name "WinRM-HTTP" -DisplayName "Windows Remote Management (HTTP-In)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5985
```

For production, configure HTTPS WinRM on port 5986.

## Troubleshooting

### Windows Connection Issues
```bash
# Test WinRM connectivity
ansible windows -i inventory/windows.yml -m win_ping

# Check WinRM on Windows server
Test-WSMan -ComputerName localhost
```

### Linux Connection Issues
```bash
# Test SSH connectivity
ansible linux -i inventory/linux.yml -m ping

# Verify Python is available
ansible linux -i inventory/linux.yml -m shell -a "which python3"
```

### View Detailed Output
```bash
# Run with verbose mode
ansible-playbook -i inventory/linux.yml configure_linux_prerequisites.yml -vvv
```

## Next Steps

After running these playbooks, you can proceed with:
1. Downloading ArcGIS Enterprise installation files from Esri
2. Transferring installers to the configured installation directory
3. Running ArcGIS Enterprise installers
4. Configuring ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store
5. Setting up ArcGIS Web Adaptor

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Open an issue in this repository
- Refer to [Esri's official ArcGIS Enterprise documentation](https://enterprise.arcgis.com/en/documentation/)

## References

- [ArcGIS Enterprise System Requirements](https://enterprise.arcgis.com/en/system-requirements/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Windows Guide](https://docs.ansible.com/ansible/latest/os_guide/windows.html)

# Halt immediately if we encounter any errors
$ErrorActionPreference = "Stop"

# Install OpenSSH server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'

# Start the SSH service after all other steps are complete so Packer may continue
Start-Service sshd
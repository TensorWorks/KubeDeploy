# Halt immediately if we encounter any errors
$ErrorActionPreference = "Stop"

Install-WindowsFeature -Name containers

Write-Output "Windows 'containers' feature installed."


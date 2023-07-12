# Halt immediately if we encounter any errors
$ErrorActionPreference = "Stop"

$installScript = 'C:\Install-Containerd.ps1'
$prepareScript = 'C:\PrepareNode.ps1'

Invoke-WebRequest https://docs.tigera.io/calico/3.26/scripts/Install-Containerd.ps1 -OutFile $installScript
Invoke-WebRequest https://docs.tigera.io/calico/3.26/scripts/PrepareNode.ps1 -OutFile $prepareScript

$scriptContent = Get-Content -Path $prepareScript
$scriptContent -creplace '--network-plugin=cni', '' -creplace '--image-pull-progress-deadline=20m', '' | Set-Content -Path $prepareScript

& $installScript -ContainerDVersion ${Env:CONTAINERD_VERSION} -CNIConfigPath "c:/etc/cni/net.d" -CNIBinPath "c:/opt/cni/bin"

& $prepareScript -KubernetesVersion ${Env:K8S_VERSION} -ContainerRuntime ContainerD

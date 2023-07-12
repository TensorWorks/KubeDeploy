packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "vm-name" {
  type    = string
  default = "K8s_Windows_Worker"
}

variable "containerd-version" {
  type    = string
  default = "1.6.8"
}

variable "k8s-version" {
  type    = string
  default = "1.24.3"
}

source "virtualbox-ovf" "k8s-windows-2022-worker" {
  source_path = "${path.root}/../../base/windows-server-2022/build/Windows_2022.ovf"
  checksum    = "none"

  // Build the VM without showing the console
  headless = false

//   // DEBUG ONLY
//   keep_registered = true
//   skip_export     = true

  ssh_username = "AdminUser"
  ssh_password = "Passw0rd!"
  ssh_timeout  = "5m"

  vm_name          = "${var.vm-name}"
  output_directory = "${path.root}/build/packer"

  // Attach autoinstall files
  cd_label = "cidata"
  cd_files = [
    "${path.root}/autoinstall/sysprep.xml",
  ]

  // shutdown_command = "shutdown -s -f -t 0"
  shutdown_command = "%WINDIR%\\system32\\sysprep\\sysprep.exe /quiet /generalize /oobe /shutdown /unattend:D:\\sysprep.xml"
}

build {
  sources = ["sources.virtualbox-ovf.k8s-windows-2022-worker"]

  # Install prerequisites
  provisioner "powershell" {
    script = "${path.root}/scripts/Install-ContainersFeature.ps1"
  }

  provisioner "windows-restart" {}

  # Install K8s
  provisioner "powershell" {
    environment_vars = [
      "CONTAINERD_VERSION=${var.containerd-version}",
      "K8S_VERSION=${var.k8s-version}",
    ]
    script = "${path.root}/scripts/Install-Kubernetes.ps1"
  }

  post-processor "vagrant" {
    provider_override = "virtualbox"
    output = "${path.root}/build/vagrant/packer_{{.BuildName}}_{{.Provider}}.box"
    // keep_input_artifact = true
  }
}

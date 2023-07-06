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
  default = "K8s_CP"
}

variable "containerd-version" {
  type    = string
  default = "1.6.8"
}

variable "runc-version" {
  type    = string
  default = "1.1.3"
}

variable "nerdctl-version" {
  type    = string
  default = "0.22.2"
}

variable "k8s-version" {
  type    = string
  default = "1.24.3"
}

variable "calico-version" {
  type    = string
  default = "3.24.1"
}

variable "rancher-version" {
  type    = string
  default = "0.0.20"
}

source "virtualbox-ovf" "k8s-control-plane" {
  source_path = "${path.root}/../../base/ubuntu-2204/build/Ubuntu_2204.ovf"
  checksum    = "none"

  // Build the VM without showing the console
  headless = true

//   // DEBUG ONLY
//   keep_registered = true
//   skip_export     = true

  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "5m"

  vm_name          = "${var.vm-name}"
  output_directory = "${path.root}/build/packer"

  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
}

build {
  sources = ["sources.virtualbox-ovf.k8s-control-plane"]

  provisioner "shell" {
    environment_vars = [
      "KEY=K8S_VERSION",
      "VALUE=${var.k8s-version}",
    ]
    script = "${path.root}/../../../scripts/set-env-var.sh"
  }

  # Install K8s prerequisites
  provisioner "shell" {
    environment_vars = [
      "CONTAINERD_VERSION=${var.containerd-version}",
      "RUNC_VERSION=${var.runc-version}",
      "NERDCTL_VERSION=${var.nerdctl-version}",
      "K8S_VERSION=${var.k8s-version}",
      "CALICO_VERSION=${var.calico-version}",
      "RANCHER_VERSION=${var.rancher-version}",
    ]
    script = "${path.root}/scripts/prepare-node.sh"
  }

  provisioner "file" {
    source      = "${path.root}/config/traefik-deployment.yaml"
    destination = "~/KubeDeploy/config/traefik-deployment.yaml"
  }

  provisioner "file" {
    source      = "${path.root}/scripts/kubeadm-init.sh"
    destination = "~/KubeDeploy/kubeadm-init.sh"
  }

  post-processor "vagrant" {
    provider_override = "virtualbox"
    output = "${path.root}/build/vagrant/packer_{{.BuildName}}_{{.Provider}}.box"
    // keep_input_artifact = true
  }
}

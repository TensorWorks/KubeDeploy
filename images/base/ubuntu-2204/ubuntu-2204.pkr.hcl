packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "ubuntu-2204" {
  guest_os_type    = "Ubuntu22_LTS_64"
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum     = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "10m"
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"

  cpus             = 2
  memory           = 4096
  disk_size        = 20000
  output_directory = "./build"

  cd_files = [
    "./autoinstall/meta-data",
    "./autoinstall/user-data",
  ]
  cd_label = "cidata"

  boot_command = [
    "<esc><wait>",
    "<c><wait>",
    "<enter><wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter><wait>",
  ]
  boot_wait = "10s"
}

build {
  sources = ["sources.virtualbox-iso.ubuntu-2204"]
}

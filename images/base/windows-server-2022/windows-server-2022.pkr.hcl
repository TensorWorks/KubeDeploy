packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

// AVMA key for Windows Server 2022 Standard
// https://docs.microsoft.com/en-us/windows-server/get-started/automatic-vm-activation
variable "product-key" {
  type    = string
  default = "YDFWN-MJ9JR-3DYRK-FXXRW-78VHK"
}

// Use "Windows Server 2022 SERVERSTANDARD" or "Windows Server 2022 SERVERDATACENTER"
variable "os-variant" {
  type    = string
  default = "Windows Server 2022 SERVERSTANDARD"
}

source "virtualbox-iso" "windows-2022" {
  // Configure source image
  guest_os_type = "Windows2022_64"
  iso_url       = "${path.root}/iso/en-us_windows_server_2022_updated_june_2023_x64_dvd_11620906.iso"
  iso_checksum  = "sha256:C2F9CA413097CD2A658E7022711A52024B8DF24CE86CD710BD331232BB266726"

  // Build the VM without showing the console
  headless = true

  // Configure SSH
  ssh_username = "AdminUser"
  ssh_password = "Passw0rd!"
  ssh_timeout  = "10m"

  // Configure build artefacts
  vm_name          = "Windows_2022"
  output_directory = "${path.root}/build"

  // Configure hardware resources
  cpus      = 2
  memory    = 4096
  disk_size = 40000

  // Attach autoinstall files
  cd_label = "cidata"
  cd_files = [
    "${path.root}/autoinstall/sysprep.xml",
    "${path.root}/scripts/Setup.ps1",
  ]
  cd_content = {
    "Autounattend.xml" = templatefile("${path.root}/autoinstall/Autounattend.xml.pkrtpl", {
      PRODUCT_KEY = var.product-key, 
      OS_VARIANT = var.os-variant,
    })
  }

  // Boot configuration
  boot_wait = "1s"

  // Define a shutdown command
  // It is important to add a shutdown_command. By default Packer halts the virtual machine and 
  // the file system may not be sync'd. Thus, changes made in a provisioner might not be saved.
  shutdown_command = "%WINDIR%\\system32\\sysprep\\sysprep.exe /quiet /generalize /oobe /shutdown /unattend:E:\\sysprep.xml"
  shutdown_timeout = "15m"
}

build {
  sources = ["sources.virtualbox-iso.windows-2022"]
}

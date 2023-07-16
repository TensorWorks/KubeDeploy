## Usage
```sh
# Build images
packer build -force ./images/base/ubuntu-2204/
packer build -force ./images/kubernetes/control-plane/
packer build -force ./images/kubernetes/linux-worker/

# Create cluster
cd ./vagrant
vagrant up

# SSH to Control Plane
vagrant ssh

# Destroy cluster
vagrant destroy -f
```
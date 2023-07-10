#!/bin/bash -e

# Allow iptables to see bridged traffic
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic
echo "=================================================="
echo "====== Configuring iptables"
echo "=================================================="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install Containerd
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md#installing-containerd
echo "=================================================="
echo "====== Installing containerd"
echo "=================================================="
mkdir -p ~/KubeDeploy
sudo apt-get update && sudo apt-get install curl -y
curl -L -o ~/KubeDeploy/containerd.tar.gz https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local ~/KubeDeploy/containerd.tar.gz

sudo mkdir -p /usr/local/lib/systemd/system
sudo curl -L -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

sudo systemctl daemon-reload
sleep 5
sudo systemctl enable --now containerd
sleep 5

curl -L -o ~/KubeDeploy/runc.amd64 https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
sudo install -m 755 ~/KubeDeploy/runc.amd64 /usr/local/sbin/runc

sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install nerdctl
# https://github.com/containerd/nerdctl
echo "=================================================="
echo "====== Installing nerdctl"
echo "=================================================="
curl -L -o ~/KubeDeploy/nerdctl.tar.gz https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
sudo tar Cxzvvf /usr/local/bin ~/KubeDeploy/nerdctl.tar.gz

# Install kubeadm, kubelet and kubectl
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
echo "=================================================="
echo "====== Installing: kubeadm kubelet kubectl"
echo "=================================================="
sudo apt-get update
sudo apt-get install -qy apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -qy kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00
sudo apt-mark hold kubelet kubeadm kubectl

# Cleanup
rm -f ~/KubeDeploy/containerd.tar.gz ~/KubeDeploy/nerdctl.tar.gz ~/KubeDeploy/runc.amd64
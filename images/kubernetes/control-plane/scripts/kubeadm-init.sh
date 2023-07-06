#!/bin/bash -e

sudo kubeadm init --kubernetes-version ${K8S_VERSION} --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=${NODE_IP}
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

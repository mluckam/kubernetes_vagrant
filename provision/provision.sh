#!/bin/bash

pushd $(dirname $0) > /dev/null

readonly IP=$1

#dependency versions
readonly KUBERNETES_CNI_VERSION="0.6.0-00"
readonly KUBERNETES_VERSION="1.9.0"
readonly KUBE_VERSION="$KUBERNETES_VERSION-00"
readonly DOCKER_VERSION="17.09.1~ce-0~ubuntu"

set -e


function configure_repos() {
    apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    -y
    
    #docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    #kubernetes
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
}


#copy configs
cp -r /tmp/configs/* /
update-ca-certificates

#update ubuntu
configure_repos
apt update
#apt upgrade -y
apt install openssh-server -y

#configuration
swapoff -a
sed '/kubernetes/d' /etc/hosts
echo "$IP kubernetes" >> /etc/hosts


#install kubernetes and dependencies
apt install kubernetes-cni=$KUBERNETES_CNI_VERSION \
  kubectl=$KUBE_VERSION \
  kubelet=$KUBE_VERSION \
  kubeadm=$KUBE_VERSION \
  docker-ce=$DOCKER_VERSION \
  -y
usermod -aG docker vagrant

echo "Environment=\"cgroup-driver=systemd/cgroup-driver=cgroupfs\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

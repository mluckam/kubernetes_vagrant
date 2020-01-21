#!/bin/bash

pushd $(dirname $0) > /dev/null

readonly IP=$1

readonly KUBERNETES_VERSION="1.9.0"
#directories
readonly HOME_DIR="/home/vagrant"

set -e

#initialize kubernetes cluster
sudo kubeadm init --kubernetes-version=$KUBERNETES_VERSION --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$IP
sudo rm -rf $HOME_DIR/.kube/*
mkdir -p $HOME_DIR/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME_DIR/.kube/config
sudo chown vagrant: $HOME_DIR/.kube
sudo chown vagrant: $HOME_DIR/.kube/config

#install kubernetes CNI flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml

#install kubernetes dashboard
#local link to dashboard 
#http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
#for remote access use kubectl proxy --address='$IP' --port=18001 --disable-filter=true
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.8.1/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default \
  --clusterrole=cluster-admin \
  --serviceaccount=default:dashboard

#configure permissive RBAC
#https://kubernetes.io/docs/reference/access-authn-authz/rbac/#permissive-rbac-permissions
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts

#remove kubernetes taint
#https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
kubectl taint nodes $(hostname) node-role.kubernetes.io/master:NoSchedule-

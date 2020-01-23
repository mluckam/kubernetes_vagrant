# README

This is a vagrant file to provide an single node kubernetes cluster installed on ubuntu.  

## Software Versions

Below is a table of current relevant versions:

| Product | Version |
| ------ | ------ |
| ubuntu | 18.04 |
| kubernetes | 1.9.0 |
| docker-ce | 17.09.1\~ce-0\~ubuntu |
| kubectl/kubelet/kubeadm | 1.9.0-00 |
| kubernetes-cni | 0.6.0-00 |

## Kubernetes Cluster

The kubernetes cluster on the provided vm is for testing puroposes only.  It is a single node cluster with Permissive RBAC Permissions and taint removed.

### Dashboard access

To access the dashboard via a browser on the host, use the following command on the vm:
```sh
kubectl proxy --address='<ip>' --port=<port> --disable-filter=true
```

Then use go to the following link, replacing \<ip\> and \<port\> with the appropriate values:
```sh
http://<ip>:<port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

When prompted for a Kubeconfig file or Token, use the skip button to bypass authentication.

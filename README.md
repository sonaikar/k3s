# k3s 

K3S provides production grade kubernetes cluster. It runs kubernetes master and agents as docker containers. 
K3S has limitation of running over Linux platform. It does not work on Mac natively. To resolve this problem we will run docker engine on a Linux virtual machine and access it remotely. K3S cluster will be provisioned over Linux Virtual machine where docker engine is running.  

More details here, 
https://k3s.io
https://rancher.com/docs/k3s/latest/en/

# k3d 

K3D is a nice wrapper over k3s to create/delete/manage kubernetes clusters.
Refer https://k3d.io/#installation for more details on K3D. 

## Provisioning cluster. 
Cluster provisioning is divided into two parts. 

1. Provision Virtual machine with Docker engine. 
- Refer `docs/01-PrepareVirtualMachine.md` for preparing virtual box with docker engine. 
- Leverage Vagrant to provision Ubuntu 20.04 Virtual machine in Virtualbox.
- Resources allocated to Virtual machine are 4 CPU and 4GB RAM. You can adjust it according to your laptop capacity. 

2. Provision k3s cluster on Virtual machine using k3d
- Refer `docs/02-installK3S.md` 
- k3d command will be executed from laptop 
- Docker daemon on Virtual machines should be accessible from laptop.
- You can create single node k3s cluster or HA cluster with 3 masters and 1 agent. 



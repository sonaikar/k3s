# Provision K3S Cluster
K3S provides production grade kubernetes cluster. K3S runs kubernetes master and agents as docker containers. 
K3S has limitation of running over Linux platform. It does not work on Mac natively. 
To resolve this problem we will run docker engine on a Linux virtual machine and access it remotely. 
K3S cluster will be provisioned over Linux Virtual machine where docker engine is provisioned.  

## Prerequisites 
- Virtual machine with docker engine running and exposed.

## Download and install K3D on mac
```bash
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

## Provision single node cluster
Provisioning cluster is easy and straight forward.
Run k3d commands with desired options. 
Get a coffee, seat back and relax while cuslter is in provision. 

```bash
k3d cluster create mycluster

# To debug you can add options --trace or --verbose to command
```

```text
➜  k3svagrant k3d cluster create mycluster
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-mycluster' (432e4b80ab8e627c70c60e7c7f63673a276cb18727200ae5e208b895e2a50392)
INFO[0000] Created volume 'k3d-mycluster-images'
INFO[0001] Creating node 'k3d-mycluster-server-0'
INFO[0007] Pulling image 'docker.io/rancher/k3s:v1.21.2-k3s1'
INFO[0013] Creating LoadBalancer 'k3d-mycluster-serverlb'
INFO[0016] Pulling image 'docker.io/rancher/k3d-proxy:v4.4.7'
INFO[0020] Starting cluster 'mycluster'
INFO[0020] Starting servers...
INFO[0020] Starting Node 'k3d-mycluster-server-0'
INFO[0028] Starting agents...
INFO[0028] Starting helpers...
INFO[0028] Starting Node 'k3d-mycluster-serverlb'
INFO[0029] (Optional) Trying to get IP of the docker host and inject it into the cluster as 'host.k3d.internal' for easy access
ERRO[0030] Exec process in node 'k3d-mycluster-server-0' failed with exit code '1'
WARN[0030] Failed to get HostIP: Failed to read address for 'host.docker.internal' from nslookup response
INFO[0030] Cluster 'mycluster' created successfully!
INFO[0030] --kubeconfig-update-default=false --> sets --kubeconfig-switch-context=false
INFO[0031] You can now use it like this:
kubectl config use-context k3d-mycluster
kubectl cluster-info
```

## Cluster should be up and ready to access
```bash
kubectl config get-contexts
CURRENT   NAME                          CLUSTER         AUTHINFO              NAMESPACE
*         k3d-mycluster                 k3d-mycluster   admin@k3d-mycluster      

kubectl get node -o wide
NAME                     STATUS   ROLES                  AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION     CONTAINER-RUNTIME
k3d-mycluster-server-0   Ready    control-plane,master   68s   v1.21.2+k3s1   172.18.0.2    <none>        Unknown    5.4.0-54-generic   containerd://1.4.4-k3s2


kubectl get po -o wide -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE   IP          NODE                     NOMINATED NODE   READINESS GATES
kube-system   metrics-server-86cbb8457f-s2wrm           1/1     Running     0          62s   10.42.0.5   k3d-mycluster-server-0   <none>           <none>
kube-system   local-path-provisioner-5ff76fc89d-hv5h5   1/1     Running     0          62s   10.42.0.3   k3d-mycluster-server-0   <none>           <none>
kube-system   coredns-7448499f4d-cvgdh                  1/1     Running     0          62s   10.42.0.2   k3d-mycluster-server-0   <none>           <none>
kube-system   helm-install-traefik-crd-nflfw            0/1     Completed   0          63s   10.42.0.6   k3d-mycluster-server-0   <none>           <none>
kube-system   helm-install-traefik-psmwz                0/1     Completed   1          63s   10.42.0.4   k3d-mycluster-server-0   <none>           <none>
kube-system   svclb-traefik-zch4v                       2/2     Running     0          33s   10.42.0.8   k3d-mycluster-server-0   <none>           <none>
kube-system   traefik-97b44b794-hj42z                   1/1     Running     0          33s   10.42.0.7   k3d-mycluster-server-0   <none>           <none>
```

## To delete cluster 
```bash
k3d cluster delete mycluster
INFO[0000] Deleting cluster 'mycluster'
INFO[0001] Deleted k3d-mycluster-serverlb
INFO[0002] Deleted k3d-mycluster-server-0
INFO[0002] Deleting cluster network 'k3d-mycluster'
INFO[0002] Deleting image volume 'k3d-mycluster-images'
INFO[0002] Removing cluster details from default kubeconfig...
INFO[0002] Removing standalone kubeconfig file (if there is one)...
INFO[0002] Successfully deleted cluster mycluster!
```


## Provision HA k3s cluster 
Provision k3s cluster with 3 masters and 1 node. 

```bash
k3d cluster create mycluster --servers 3 --agents 1
INFO[0002] Prep: Network
INFO[0002] Created network 'k3d-mycluster' (244c9fe55835d1e521e9ae4ae67b5b3af699b7bc79087640ebecabf45eaf805b)
INFO[0002] Created volume 'k3d-mycluster-images'
INFO[0002] Creating initializing server node
INFO[0002] Creating node 'k3d-mycluster-server-0'
INFO[0005] Creating node 'k3d-mycluster-server-1'
INFO[0006] Creating node 'k3d-mycluster-server-2'
INFO[0009] Creating node 'k3d-mycluster-agent-0'
INFO[0009] Creating LoadBalancer 'k3d-mycluster-serverlb'
INFO[0009] Starting cluster 'mycluster'
INFO[0009] Starting the initializing server...
INFO[0010] Starting Node 'k3d-mycluster-server-0'
INFO[0012] Starting servers...
INFO[0012] Starting Node 'k3d-mycluster-server-1'
INFO[0038] Starting Node 'k3d-mycluster-server-2'
INFO[0055] Starting agents...
INFO[0055] Starting Node 'k3d-mycluster-agent-0'
INFO[0071] Starting helpers...
INFO[0071] Starting Node 'k3d-mycluster-serverlb'
INFO[0072] (Optional) Trying to get IP of the docker host and inject it into the cluster as 'host.k3d.internal' for easy access
ERRO[0073] Exec process in node 'k3d-mycluster-server-0' failed with exit code '1'
WARN[0073] Failed to get HostIP: Failed to read address for 'host.docker.internal' from nslookup response
INFO[0073] Cluster 'mycluster' created successfully!
INFO[0073] --kubeconfig-update-default=false --> sets --kubeconfig-switch-context=false
INFO[0074] You can now use it like this:
kubectl config use-context k3d-mycluster
kubectl cluster-info
```

## Verify cluster resources 
```bash
kubectl get no -o wide
NAME                     STATUS   ROLES                       AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION     CONTAINER-RUNTIME
k3d-mycluster-agent-0    Ready    <none>                      39s   v1.21.2+k3s1   172.19.0.5    <none>        Unknown    5.4.0-54-generic   containerd://1.4.4-k3s2
k3d-mycluster-server-0   Ready    control-plane,etcd,master   88s   v1.21.2+k3s1   172.19.0.2    <none>        Unknown    5.4.0-54-generic   containerd://1.4.4-k3s2
k3d-mycluster-server-1   Ready    control-plane,etcd,master   71s   v1.21.2+k3s1   172.19.0.3    <none>        Unknown    5.4.0-54-generic   containerd://1.4.4-k3s2
k3d-mycluster-server-2   Ready    control-plane,etcd,master   56s   v1.21.2+k3s1   172.19.0.4    <none>        Unknown    5.4.0-54-generic   containerd://1.4.4-k3s2
```

## Verify on Linux server 
You will observe below docker containers running on Linux server. 

```bash
 docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                             NAMES
0ce436e8381d   rancher/k3d-proxy:v4.4.7   "/bin/sh -c nginx-pr…"   3 minutes ago   Up 2 minutes   80/tcp, 0.0.0.0:57407->6443/tcp   k3d-mycluster-serverlb
3c0d45e5a119   rancher/k3s:v1.21.2-k3s1   "/bin/k3s agent"         3 minutes ago   Up 2 minutes                                     k3d-mycluster-agent-0
6358a54d1357   rancher/k3s:v1.21.2-k3s1   "/bin/k3s server --t…"   3 minutes ago   Up 2 minutes                                     k3d-mycluster-server-2
3f49a2329ff4   rancher/k3s:v1.21.2-k3s1   "/bin/k3s server --t…"   3 minutes ago   Up 3 minutes                                     k3d-mycluster-server-1
3fa06e49151b   rancher/k3s:v1.21.2-k3s1   "/bin/k3s server --c…"   3 minutes ago   Up 3 minutes                                     k3d-mycluster-server-0
```
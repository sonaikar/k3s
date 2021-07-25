# Prepare Virtual machine for docker engine

## Prerequisites
- Virtualbox : version v6.1.22 at the time of this demo 
- Vagrant :  version 2.2.16

### Provision virtualbox 
```bash
# Enter into directory where Vagrantfile is copied
# Make sure to modify priavte IP address/Public IP address and network name in Vagrantfile
cd ~/k3svagrant/
vagrant up 

# Virtual box will be created and reachable via bridge IP address.
# You can login into virtualbox using vagrant ssh 

vagrant ssh

# Docker engine would be installed on virtual box through provision script
docker info 


  
```
```text
System information as of Sun Jul 25 14:14:44 UTC 2021

System load:              0.12
Usage of /:               5.2% of 38.71GB
Memory usage:             8%
Swap usage:               0%
Processes:                137
Users logged in:          0
IPv4 address for docker0: 172.17.0.1
IPv4 address for enp0s3:  10.0.2.15
IPv4 address for enp0s8:  10.0.0.120
IPv6 address for enp0s8:  2607:fea8:da1:a600::99c1
IPv6 address for enp0s8:  2607:fea8:da1:a600:a00:27ff:fe36:f58
IPv4 address for enp0s9:  192.168.56.120
```

```text
vagrant@k3smaster:~$ docker info
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  app: Docker App (Docker Inc., v0.9.1-beta3)
  buildx: Build with BuildKit (Docker Inc., v0.5.1-docker)
  scan: Docker Scan (Docker Inc., v0.8.0)

Server:
 Server Version: 20.10.7
```


### Download file from github to generate certificates.
curl https://raw.githubusercontent.com/kekru/linux-utils/master/cert-generate/create-certs.sh -o create-certs.sh
chmod +x create_certs.sh

### Generate server and client certificates.
./create-certs.sh -m ca -pw password -t certs -e 900
./create-certs.sh -m server -h k3smaster -hip 10.0.0.120 -pw password -t certs -e 365
./create-certs.sh -m client -h mylaptop -pw password -t certs -e 365

### Below certificates would be available
ls -lart certs

```text
total 48
-r--------@  1 sonaikar  staff  3326 25 Jul 09:01 ca-key.pem
-r--------@  1 sonaikar  staff  1996 25 Jul 09:01 ca.pem
-r--------@  1 sonaikar  staff  3247 25 Jul 09:02 server-key.pem
-r--------@  1 sonaikar  staff  1883 25 Jul 09:02 server-cert.pem
-r--------@  1 sonaikar  staff  3243 25 Jul 09:04 client-mylaptop-key.pem
-r--------@  1 sonaikar  staff  1883 25 Jul 09:04 client-mylaptop-cert.pem
drwxr-xr-x@  8 sonaikar  staff   256 25 Jul 09:04 .
drwxr-xr-x@ 11 sonaikar  staff   352 25 Jul 10:18 ..
```
### Copy certificates to virtual box
ssh vagrant@10.0.0.120 "sudo mkdir /data/certs"
ssh vagrant@10.0.0.120 "sudo chmod 777 /data/certs"
scp certs/ca.pem certs/server-key.pem certs/server-cert.pem vagrant@10.0.0.120:/data/certs/
ssh vagrant@10.0.0.120 "sudo chmod 755 /data/certs"
ssh vagrant@10.0.0.120 "sudo chown -R root: /data/certs"

### Cert directory on server looks like below.
```text
root@k3smaster:/data# ls -lart certs/
total 32
drwxr-xr-x 3 root root 4096 Jul 25 13:07 ..
-r-------- 1 root root 3247 Jul 25 13:08 server-key.pem
-r-------- 1 root root 1883 Jul 25 13:08 server-cert.pem
-r-------- 1 root root 1996 Jul 25 13:08 ca.pem
```

### Create  docker daemon.json on virtual machine to use tls certificates.
```bash

vagrant ssh 
sudo -i 

cat <<EOF >>/etc/docker/daemon.json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
  "tls": true,
  "tlscacert": "/data/certs/ca.pem",
  "tlscert": "/data/certs/server-cert.pem",
  "tlskey": "/data/certs/server-key.pem",
  "tlsverify": true,
  "insecure-registry": ["10.96.0.0/12"]
}
EOF



# Restart docker daemon and ensure service is running as expected.
systemctl daemon-reload
systemctl restart docker
```


# Copy client certificates to desired directory on your laptop
mkdir -p ~/.k3svagrant/certs
cp client-mylaptop-cert.pem ~/.k3svagrant/certs/cert.pem
cp client-mylaptop-key.pem ~/.k3svagrant/key.pem
cp ca.pem  ~/.k3svagrant/certs/ca.pem

# Directory should look like this,
➜  certs ll ~/.k3svagrant/certs
total 24
drwxr-xr-x  3 sonaikar  staff    96 24 Jul 16:02 ..
-r--------@ 1 sonaikar  staff  1883 25 Jul 09:16 cert.pem
-r--------@ 1 sonaikar  staff  3243 25 Jul 09:16 key.pem
-r--------@ 1 sonaikar  staff  1996 25 Jul 09:16 ca.pem
drwxr-xr-x  5 sonaikar  staff   160 25 Jul 09:19 .

# Create a file on laptop to set docker host connection
➜  k3svagrant cat k3sdocker.sh
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://10.0.0.120:2376"
export DOCKER_CERT_PATH="/Users/sonaikar/.k3svagrant/certs"

# Source the file in environment.
source k3sdocker.sh

# Docker command should be success
docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

# Create an alias in .bashrc/.zshrc file to load docker environment
alias k3sdocker='source ~/k3svagrant/k3sdocker.sh'
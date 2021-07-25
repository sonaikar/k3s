#!/usr/bin/env bash

apt-get update
echo "### Installing docker dependncies"
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
echo "### Add docker repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
echo "### Policy docker"
apt-cache policy docker-ce
echo "### Installing docker"
sudo apt install docker-ce -y

echo "### Docker daemon status"
sudo systemctl status docker

echo "### Add vagrant to docker group"
sudo usermod -aG docker vagrant


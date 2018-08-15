#!/bin/sh

DOCKER="${DOCKER_VERSION:-17.03}"
KUBERNETES="${KUBERNETES_VERSION:-1.11.1}"

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

apt-get update

apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep "$DOCKER" | head -1 | awk '{print $3}')
apt-get install -y kubeadm=$(apt-cache madison kubeadm | grep "$KUBERNETES" | head -1 | awk '{print $3}')

swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

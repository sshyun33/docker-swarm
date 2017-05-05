#!/bin/bash

DOCKER_USER=$(id -un)
DOCKER_COMPOSE_VERSION=1.12.0

sudo apt-get clean
sudo apt-get remove docker docker-engine

sudo apt-get update

sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce

sudo usermod -aG docker ${DOCKER_USER}

sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/\'${DOCKER_COMPOSE_VERSION}'/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose' && 
  sudo chmod +x /usr/local/bin/docker-compose

#!/bin/bash

UBUNTU_VERSION=xenial
USER=ubuntu
DOCKER_COMPOSE_VERSION=1.11.2

sudo apt-get clean
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_VERSION stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER


sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/\'${DOCKER_COMPOSE_VERSION}'/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
sudo chmod +x /usr/local/bin/docker-compose

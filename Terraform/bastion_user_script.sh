#!/bin/bash

sudo apt-get update -y
sudo apt install snapd -y

# install AWS CLI
sudo snap install aws-cli --classic
# install kubectl
sudo snap install kubectl --classic
# install helm
sudo snap install helm --classic  
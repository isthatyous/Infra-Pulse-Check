#!/bin/bash

# Install java 
sudo apt update 
sudo apt install -y fontconfig openjdk-17-jre



# Install Jenkins
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get -y install jenkins

# start jenikns
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt-get update
sudo apt-get install docker.io -y


# user group permissions
sudo usermod -aG docker ubuntu 
sudo usermod -aG docker jenkins


# Restart services
sudo systemctl restart docker
sudo systemctl restart jenkins

# Install Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

# Install SonarQubess
sudo docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:community



# Install AWS CLI
sudo snap install aws-cli --classic

# Install Helm
sudo snap install helm --classic
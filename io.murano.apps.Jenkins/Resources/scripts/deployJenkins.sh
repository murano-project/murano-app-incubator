#!/bin/bash

#install requirements
sudo wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update

# Jenkins
sudo apt-get -y install jenkins

sudo sed -e "s/^START=no/START=yes/" -i /etc/default/jenkins
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by Murano, Jenkins"
sudo service jenkins restart

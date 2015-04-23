#!/bin/bash
WAR="$1"

# Update the packages and install git and java
apt-get update
apt-get install -y git openjdk-7-jdk git-review

# Create a user, gerrit2, to run gerrit
useradd -d/home/gerrit2 gerrit2
mkdir /home/gerrit2
chown -R gerrit2:gerrit2 /home/gerrit2

# Allow firewall holes for Gerrit
iptables -I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, Apache server access on HTTP on port 8080"
iptables -I INPUT 1 -p tcp -m tcp --dport 29418 -j ACCEPT -m comment --comment "by murano, Apache server access on sshd on port 29418"

# Download latest stable code, install and remove war file. 
cd /tmp
wget ${WAR}
filename=$(basename ${WAR})
sudo -u gerrit2 java -jar /tmp/$filename init --batch -d /home/gerrit2/gerrit_testsite
rm /tmp/$filename

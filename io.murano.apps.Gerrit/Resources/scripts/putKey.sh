#!/bin/bash
SSHKEY="$1"

mkdir /home/gerrit/.ssh
echo $SSHKEY > /home/gerrit/.ssh/authorized_keys 
chmod 700 /home/gerrit/.ssh
chown -R gerrit:gerrit /home/gerrit/.ssh

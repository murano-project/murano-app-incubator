#!/bin/sh

yum -y upgrade

# I have occasionally seen 'yum install' fail with errors
# trying to contact mirrors.  Because it can be a pain to
# delete and re-create the stack, just loop here until it
# succeeds.
while :; do
  yum -y install docker-io
  [ -x /usr/bin/docker ] && break
  sleep 5
done

# Add a tcp socket for docker
cat > /etc/systemd/system/docker-tcp.socket <<EOF
[Unit]
Description=Docker remote access socket

[Socket]
ListenStream=2375
BindIPv6Only=both
Service=docker.service

[Install]
WantedBy=sockets.target
EOF

# Start and enable the docker service.
for sock in docker.socket docker-tcp.socket; do
  systemctl start $sock
  systemctl enable $sock
done


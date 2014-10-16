#!/bin/bash

sudo apt-get -y -q install postgresql
sed -e "s/^#listen_addresses =.*$/listen_addresses = \'*\'/" -i /etc/postgresql/*/main/postgresql.conf
add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 5432 -j ACCEPT -m comment --comment "by murano, PostgreSQL"'
sudo /etc/init.d/postgresql restart


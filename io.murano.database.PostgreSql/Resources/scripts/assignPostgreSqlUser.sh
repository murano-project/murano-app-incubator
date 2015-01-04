#!/bin/bash

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE '$1' to '$2'"
echo "host $1 $2 all md5" >> /etc/postgresql/*/main/pg_hba.conf
sudo /etc/init.d/postgresql restart

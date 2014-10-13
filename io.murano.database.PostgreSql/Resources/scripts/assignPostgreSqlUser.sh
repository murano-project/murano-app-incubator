#!/bin/bash

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $1 to $2"

#It's necessary to know the current version of PostreSql. Maybe there needs modification.
VER=$(psql --version 2>&1 | tail -1 | awk '{print $3}' | sed 's/\./ /g' | awk '{print $1 "." $2}')

sudo echo "host $1 $2 all md5" >> /etc/postgresql/$VER/main/pg_hba.conf
sudo /etc/init.d/postgresql restart





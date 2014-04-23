#!/bin/bash

function include(){
    curr_dir=$(cd $(dirname "$0") && pwd)
    inc_file_path=$curr_dir/$1
    if [ -f "$inc_file_path" ]; then
        . $inc_file_path
    else
        echo -e "$inc_file_path not found!"
        exit 1
    fi
}
include "common.sh"

get_os
[[ $? -ne 0 ]] && exit 1
if [[ "$DistroBasedOn" != "redhat" ]]; then
    DEBUGLVL=4
    log "ERROR: We are sorry, only \"redhat\" based distribution of Linux supported for this service type, exiting!"
    exit 1
fi


su -c "psql -d postgres -c \"CREATE DATABASE $1\"" -s /bin/sh postgres
su -c "psql -d postgres -c \"CREATE USER $2 WITH PASSWORD '$3'\"" -s /bin/sh postgres
su -c "psql -d postgres -c \"GRANT ALL PRIVILEGES ON DATABASE $1 to $2;\"" -s /bin/sh postgres
echo "host $1 $2 all md5" >> /var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql.service

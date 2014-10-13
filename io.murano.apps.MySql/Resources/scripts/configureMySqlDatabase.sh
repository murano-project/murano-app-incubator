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
if [[ "$DistroBasedOn" != "debian" ]]; then
    DEBUGLVL=4
    log "ERROR: We are sorry, only \"debian\" based distribution of Linux supported for this service type, exiting!"
    exit 1
fi


su -c "mysql --user=root --password==root -e \"CREATE DATABASE $1\"" -s /bin/sh mysql
su -c "mysql --user=root --password==root -e \"CREATE USER '$2'@'localhost' IDENTIFIED BY '$3'\"" -s /bin/sh mysql	
su -c "mysql --user=root --password==root -e \"GRANT ALL PRIVILEGES ON DATABASE $1 to '$2'@'localhost' WITH GRANT OPTION;\"" -s /bin/sh mysql
su -c "mysql --user=root --password==root -e \"CREATE USER '$2'@'%' IDENTIFIED BY '$3'\"" -s /bin/sh mysql	
su -c "mysql --user=root --password==root -e \"GRANT ALL PRIVILEGES ON DATABASE $1 to '$2'@'%' WITH GRANT OPTION;\"" -s /bin/sh mysql	


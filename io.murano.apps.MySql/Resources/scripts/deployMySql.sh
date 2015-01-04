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

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

bash installer.sh -p sys -i "mysql-server"

sed -e "s/^bind-address*/#bind-address/" -i /etc/mysql/my.cnf

#service mysql restart

add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 3306 -j ACCEPT -m comment --comment "by murano, MySQL"'

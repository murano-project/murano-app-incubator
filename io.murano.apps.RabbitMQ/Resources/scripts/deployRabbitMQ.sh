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

echo 'deb http://www.rabbitmq.com/debian/ testing main' >> /etc/apt/sources.list
wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add rabbitmq-signing-key-public.asc
apt-get update
bash installer.sh -p sys -i "rabbitmq-server"

FW_RULE1='-I INPUT 1 -p tcp -m tcp --dport 5672 -j ACCEPT -m comment --comment "by murano, RabbitMQ server"'
FW_RULE2='-I INPUT 1 -p tcp -m tcp --dport 15672 -j ACCEPT -m comment --comment "by murano, Web interface for RabbitMQ server"'

echo '[{rabbit, [{loopback_users, []}]}].' >> /etc/rabbitmq/rabbitmq.config

sudo rabbitmq-plugins enable rabbitmq_management >> /tmp/rabbitmq.log
sudo invoke-rc.d rabbitmq-server restart >> /tmp/rabbitmq.log

add_fw_rule $FW_RULE1
add_fw_rule $FW_RULE2
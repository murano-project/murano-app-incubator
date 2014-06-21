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
. ~/.profile

cd /root

NATS_IP=$1

cd dea_ng

file=config/dea.yml

sed -i.bak "s/127.0.0.1:3456/$NATS_IP/g" $file
sed -i.bak "s/loggregatorsharedsecret/c1oudc0w/g" $file
sed -i.bak "s/localhost/$NATS_IP/g" $file

screen -d -m bin/dea config/dea.yml
#!/bin/bash

curr_dir=$(cd $(dirname "$0") && pwd)

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

cd /root

cd murano

file=etc/murano/murano.conf
cp -f $curr_dir/murano.conf $file
sed -i.bak "s/%MQ_HOST%/$1/g" $file
sed -i.bak "s/%MQ_USER%/$4/g" $file
sed -i.bak "s/%MQ_PASS%/$5/g" $file
sed -i.bak "s/%MQ_VHOST%/$6/g" $file
sed -i.bak "s/%IAAS_IP%/$1/g" $file
sed -i.bak "s/%IAAS_USER%/$2/g" $file
sed -i.bak "s/%IAAS_PASS%/$3/g" $file

murano-manage --config-file $file db-sync

screen -d -m murano-api --config-file $file

screen -d -m murano-engine --config-file $file


#add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, CloudFoundry"'



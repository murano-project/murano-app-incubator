#!/bin/bash
echo "Very first line"
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
#include "common.sh"

curr_dir=$(cd $(dirname "$0") && pwd)
file=/root/admin-ui/config/admconfig.yml

#log "DEBUG: CFUI"
cp -f $curr_dir/admconfig.yml $file
sed -i.bak "s/%IP%/$1/g" $file
sed -i.bak "s/%USER%/$2/g" $file
sed -i.bak "s/%PASS%/$3/g" $file


screen -d -m "cd /root/admin_ui && ruby bin/admin -c /root/admin_ui/config/admconfig.yml"


#add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, CloudFoundry"'



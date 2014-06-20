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

bash installer.sh -p sys -i "curl git"

cd /root
log "DEBUG: cloning cf_nise_installer"
git clone https://github.com/yudai/cf_nise_installer

cd cf_nise_installer

log "DEBUG: running bootstrap.sh"
bash ./scripts/install.sh > install.log

wget https://s3.amazonaws.com/go-cli/releases/v6.1.2/cf-cli_amd64.deb

dpkg --install cf-cli_amd64.deb


#add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, CloudFoundry"'



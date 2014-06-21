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

rbenv install 1.9.3-p547

git clone https://github.com/cloudfoundry/warden

cd warden

cd /warden/warden
bundle install
bundle exec rake warden:start[config/linux.yml] &> /tmp/warden.log &


git clone https://github.com/cloudfoundry/dea_ng
cd dea_ng
git submodule update --init
bundle install


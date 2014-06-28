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

function install_debian(){
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
    apt-get update
    apt-get -y install mongodb-org
}

function install_centos() {
  echo "Not implemented"
}

get_os
[[ $? -ne 0 ]] && exit 1
case $DistroBasedOn in
    "debian")
       install_debian
        ;;
    "redhat")
        install_centos
	XINIT_CFG=1
        ;;
esac

service mongod stop

cp -f $curr_dir/mongodb.conf /etc/mongod.conf
sed -i.bkp "s/%REPSET%/$1/g" /etc/mongod.conf

service mongod start


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

cd /root

sudo apt-get update

apt-get install -y python-dev python-mysqldb libxml2-dev libxslt1-dev libffi-dev python-openssl mysql-client libmysqlclient-dev libpq-dev wget git make gcc python-pip python-setuptools python-lxml python-crypto ntpdate libsqlite3-dev libldap-dev libldap2-dev libsasl2-dev

bash installer.sh -p sys -i "python-pip curl git"
bash installer.sh -p sys -i "wget git make gcc python-pip python-setuptools python-lxml python-crypto ntpdate"
bash installer.sh -p sys -i "python-dev python-mysqldb libxml2-dev libxslt1-dev libffi-dev python-openssl mysql-client"

cd /root

git clone https://github.com/openstack/requirements

cd requirements
sudo pip install -r global-requirements.txt | tee /tmp/global-req.log

cd ..

log "DEBUG: cloning $1"
git clone $1

cd murano

log "DEBUG: switch branch to $2"
git checkout $2


sudo pip install -r requirements.txt | tee /tmp/muralo-req.log
sudo pip install --upgrade 'setuptools>=0.8'

sudo python setup.py install | tee /tmp/murano-install.log

add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8082 -j ACCEPT -m comment --comment "by murano, Murano API"'
add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8083 -j ACCEPT -m comment --comment "by murano, Murano CF API"'



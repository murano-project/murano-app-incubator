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

bash installer.sh -p sys -i "nodejs"

cd /root

git clone https://github.com/openstack/horizon

cd horizon
git checkout stable/icehouse
sudo pip install -r requirements.txt
python setup.py install


cd ..

wget -q --no-check-certificate https://dl.dropboxusercontent.com/u/486062/horizon-2014.1.dev1.g8d0b69d.tar.gz

tar xzf horizon-2014.1.dev1.g8d0b69d.tar.gz
cd horizon-2014.1.dev1.g8d0b69d
sudo pip install -r requirements.txt
sudo python setup.py install

cd ..

git clone $2
cd murano-dashboard
git checkout $3

sudo pip install -r requirements.txt

file=muranodashboard/local/local_settings.py
cp -f $curr_dir/settings.py muranodashboard/
cp -f $curr_dir/local_settings.py muranodashboard/local/

sed -i.bak "s/%KEYSTONE_IP%/$1/g" $file

python setup.py install

# New version of django does not work
# with current horizon
#pip uninstall django
#pip install "django==1.5.6"

python manage.py syncdb --noinput

screen -d -m python manage.py runserver 0.0.0.0:8080


#add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, CloudFoundry"'



#!/bin/bash
#
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
curr_dir=$(cd $(dirname "$0") && pwd)
# FirewallRules
FW_RULE1='-I INPUT 1 -p tcp -m tcp --dport 9418 -j ACCEPT -m comment --comment "by murano, Git server access"'
APP=''
XINIT_CFG=0
get_os
[[ $? -ne 0 ]] && exit 1
case $DistroBasedOn in
    "debian")
        APP="git"
        ;;
    "redhat")
        APP="git-core"
	XINIT_CFG=1
        ;;
esac

APPS_TO_INSTALL="$APP"
bash ./installer.sh -p sys -i $APPS_TO_INSTALL
bash ./installer.sh -p sys -i "screen"

repo=$1
echo $repo >> /tmp/install.log
mkdir -p /opt/git
mkdir -p /opt/git/$repo
cd /opt/git/$repo
git init --bare --shared >> /tmp/install.log
touch git-daemon-export-ok

cp $curr_dir/git-service /etc/init.d
chmod a+x /etc/init.d/git-service
service git-service start

add_fw_rule $FW_RULE1
exit 0
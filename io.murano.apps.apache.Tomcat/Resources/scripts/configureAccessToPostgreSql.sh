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
if [[ "$DistroBasedOn" != "redhat" ]]; then
    DEBUGLVL=4
    log "ERROR: We are sorry, only \"redhat\" based distribution of Linux supported for this service type, exiting!"
    exit 1
fi

sed -e "s/YOURUSERNAMEHERE/$2/" -i /usr/share/tomcat/webapps/app/META-INF/context.xml
sed -e "s/YOURPASSWORDHERE/$3/" -i /usr/share/tomcat/webapps/app/META-INF/context.xml
sed -e "s/YOURHOSTHERE/$4/" -i /usr/share/tomcat/webapps/app/META-INF/context.xml
sed -e "s/YOURDATABASEHERE/$1/" -i /usr/share/tomcat/webapps/app/META-INF/context.xml

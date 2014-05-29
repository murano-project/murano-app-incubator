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

bash installer.sh -p sys -i "java-devel"

cd /usr/share/tomcat/webapps
log "DEBUG: git-cloning $1 to $2"
git clone $1 $2
cd $2/WEB-INF/classes
for f in $(find . -name "*.java"); do
    javac -cp /usr/share/tomcat/lib/tomcat-servlet-3.0-api.jar "$f"
done

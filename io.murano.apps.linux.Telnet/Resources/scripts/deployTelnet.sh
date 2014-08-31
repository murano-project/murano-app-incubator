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

# FirewallRules
FW_RULE1='-I INPUT 1 -p tcp -m tcp --dport 23 -j ACCEPT -m comment --comment "by murano, Telnet server access on port 23"'

APP=''
INIT_SYSTEM=''

get_os || exit 1

case $DistroBasedOn in
    "debian")
        APP="telnetd"
        INIT_SYSTEM='sysv'
        SERVICE_NAME='telnetd'
    ;;
    "redhat")
        APP="telnet-server"
        INIT_SYSTEM='xinetd'
        if [ "${DIST}" == 'Fedora' -a "${REV}" -ge 20 ]; then
            #APP="${APP} xinetd"
            INIT_SYSTEM='systemd'
            SERVICE_NAME='telnet.socket'
        fi
    ;;
    *)
        echo "'$DistroBasedOn' is not supported."
        exit 1
    ;;
esac

# Install required packages using external tool
bash installer.sh -p sys -i "$APP"

# Enable and start Telnet service using available init system
case ${INIT_SYSTEM} in
    'sysv')
        service ${SERVICE_NAME} start
    ;;
    'xinetd')
        xinetd_tlnt_cfg="/etc/xinetd.d/telnet"
        if [ -f "$xinetd_tlnt_cfg" ]; then
            sed -i '/disable.*=/ s/yes/no/' $xinetd_tlnt_cfg
            if [ $? -ne 0 ]; then
                log "can't modify $xinetd_tlnt_cfg"
                exit 1
            fi
        else
        log "$APP startup config not found under $xinetd_tlnt_cfg"
        fi
        #security tty for telnet
        setty=/etc/securetty
        lines=$(sed -ne '/^pts\/[0-9]/,/^pts\/[0-9]/ =' ${setty})
        if [ -z "$lines" ]; then
            for i in $(seq 0 9); do
                echo "pts/${i}" >> ${setty}
                if [ $? -ne 0 ]; then
                    log "Error occured during ${setty} changing..."
                    exit 1
                fi
            done
        else
            echo "$setty has pts/0-9 options..."
        fi
        restart_service xinetd
    ;;
    'systemd')
        systemctl enable ${SERVICE_NAME}
        systemctl start ${SERVICE_NAME}
        #firewall-cmd --permanent --add-service=telnet
        #firewall-cmd --reload
    ;;
    *)
        echo "Inititalization system '${INIT_SYSTEM}' is not supported."
        exit 1
    ;;
esac

add_fw_rule $FW_RULE1

#!/bin/bash
#    Copyright (c) 2014 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
RUN_DIR=$(cd $(dirname "$0") && pwd)
APPLICATION_NAME="murano applications packages"
DAEMON_USER=${DAEMON_USER:-"murano"}
DAEMON_GROUP=${DAEMON_GROUP:-"murano"}
DAEMON_CONF="/etc/murano/murano.conf"
MANAGE_CMD=$(which murano-manage)
#
function preinstall_check()
{
    local retval=0
    local warn_message=" Please, install murano-api first or reset \$DAEMON_GROUP and \$DAEMON_USER variables!"
    getent group $DAEMON_GROUP > /dev/null
    if [ $? -ne 0 ]; then
        echo "System group $DAEMON_GROUP not found!${warn_message}"
        retval=1
    fi
    getent passwd $daemonuser > /dev/null
    if [ $? -ne 0 ]; then
        echo "System user $DAEMON_USER not found!${warn_message}"
        retval=1
    fi
    if [ ! -f "$MANAGE_CMD" ]; then
        echo "murano-manage not found!${warn_message}"
        retval=1
    fi
    if [ ! -f "$DAEMON_CONF" ]; then
        echo "$DAEMON_CONF not found!${warn_message}"
        retval=1
    fi
    return $retval
}

function install_applications()
{
    local retval=0
    local src_meta_dir="$RUN_DIR"
    if [ -d "$src_meta_dir" ]; then
        for package_dir in $(ls $src_meta_dir); do
            if [ -d "${src_meta_dir}/${package_dir}" ]; then
                su -c "$MANAGE_CMD --config-file $DAEMON_CONF import-package ${src_meta_dir}/${package_dir}" -s /bin/bash $DAEMON_USER 2>&1
                if [ $? -ne 0 ]; then
                    echo "Error occured during ${package_dir} import, exiting!"
                    retval=1
                    break
                fi
            fi
        done
    else
        echo "Warning: $src_meta_dir not found!"
        retval=1
    fi
    return $retval
}
# Command line args'
COMMAND="$1"
case $COMMAND in
    install)
        echo "Installing \"$APPLICATION_NAME\" to system..."
        preinstall_check || exit $?
        install_applications || exit $?
        ;;

    * )
        echo -e "Usage: $(basename "$0") [command] \nCommands:\n\tinstall - Install \"$APPLICATION_NAME\" software"
        exit 1
        ;;
esac
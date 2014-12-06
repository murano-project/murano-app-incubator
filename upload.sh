#!/bin/bash -x

# PARAMS
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
MURANO_IP="localhost"
MURANO_PORT="8082"

# FUNCTIONS
function check_succsess {
    if [ $? -ne 0 ]; then
        echo "...can't finish copy operation"
        exit 1
    else
        echo "...SUCCESS"
    fi
}

function create_package {
    local package=$1

    if ! file --mime-type "$package" | grep -q "application/zip"; then
        if [[ -z "$package" ]]; then
            echo "No directory or zip file provided."
            exit
        fi

        if [[ ! -d "${package}" ]]; then
            echo "Folder '${package}' doesn't exist."
            exit
        fi
        # Remove ending slash
        package=${package%/*}

        pushd ${package}

        PACKAGE="${SCRIPT_DIR}/${PACKAGE}.zip"
        echo "NAME = ${PACKAGE}"
        zip -r -q ${PACKAGE} *
        check_succsess
        popd
    fi
}

# MAIN SCRIPT

usage="
Usage: upload.sh zip_package|directory_name [--rc]|[--tenant-name][--murano-ip][--murano-port]
  Options:
   * --rc:      Openstack RC file. It can be download from horizon at 'Project -> Access & Security' page
   * --murano-ip      IP where Murano is running. Default is localhost
   * --murano-port    Port where Murano is running. Default is 8082
   * --tenant-name:   .....

  Parameters:
   * zip_package:     Already zipped Murano package
   * directory_name:  Directory name, witch contains all files, needed by Murano package
"

if [ "$*" == "" ] || [ "$*" == "-h" ] || [ "$*" == "--help" ]; then
    echo "$usage"
    exit 1
fi

PACKAGE="$1"
shift

while [[ "$#" -gt 1 ]]
do
    key="$1"
    shift

    case "$key" in
        --rc)
            RC_FILE="$1"
            shift
            ;;
        --murano-ip)
            MURANO_IP="$1"
            shift
            ;;
        --murano-port)
            MURANO_PORT="$1"
            shift
            ;;
        *)
            echo "$usage"
            exit 1
            ;;
    esac
done

create_package ${PACKAGE}
echo "PACKAGE = ${PACKAGE}"
echo "RC_FILE = ${RC_FILE}"

source ${RC_FILE}
check_succsess
sudo apt-get -y -q install python-pip
sudo pip -q install python-muranoclient

murano --murano-url http://${MURANO_IP}:${MURANO_PORT} package-import ${PACKAGE}
check_succsess
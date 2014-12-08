#!/bin/bash -x

# PARAMS
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
MURANO_IP="localhost"
MURANO_PORT="8082"

# FUNCTIONS
function die {
    echo "$@"
    exit 1
}


function check_and_create_package {
    local package=$1
    if [[ -z "$package" ]]; then
        die "No directory or zip file provided."
    fi    
    if [[ -f "$package" ]]; then
        if file --mime-type "$package" | grep -q "application/zip"; then
            return
        else
            die "File and not zip"
        fi
    fi
        
    if [[ -d "${package}" ]]; then
        # Remove ending slash
        package=${package%/*}

        pushd ${package}

        PACKAGE="${SCRIPT_DIR}/${package}.zip"
        zip -r -q ${PACKAGE} * || die "Can't create zip archive"
        popd
    else
        die "Folder '${package}' doesn't exist."
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
    die "$usage"
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
            die "$usage"
            ;;
    esac
done

check_and_create_package ${PACKAGE}
echo "PACKAGE = ${PACKAGE}"
echo "RC_FILE = ${RC_FILE}"

source ${RC_FILE}

sudo apt-get -y -q install python-pip
sudo pip -q install python-muranoclient

murano --murano-url http://${MURANO_IP}:${MURANO_PORT} package-import ${PACKAGE} || die "Unable to import package '${PACKAGE}'"

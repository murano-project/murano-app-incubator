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

bash installer.sh -p sys -i "curl git wget"
cd /root

if [ ! -d ~/.rbenv ]; then
    sudo apt-get -y install build-essential libreadline-dev libssl-dev zlib1g-dev git-core
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
    echo 'eval "$(rbenv init -)"' >> ~/.profile
fi
source ~/.profile
if ! (rbenv versions | grep -q 1.9.3-p547); then
    rbenv install 1.9.3-p547
fi
rbenv global 1.9.3-p547

gem install bundler --no-rdoc --no-ri

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
sudo apt-get update

bash installer.sh -p sys -i "git-core build-essential libssl-dev ruby ruby-gem gcc make bundle"

cd /root


log "DEBUG: Install Ruby"

cd /root
log "DEBUG: cloning cf_nise_installer"
git clone https://github.com/yudai/cf_nise_installer

cd cf_nise_installer

log "DEBUG: running bootstrap.sh"
bash ./scripts/install_ruby.sh > install.log
cd ..

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(~/.rbenv/bin/rbenv init -)"' >> ~/.profile
. ~/.profile

log "DEBUG: cloning CF admin UI"
git clone https://github.com/cloudfoundry-incubator/admin-ui
cd admin-ui

rbenv global 1.9.3-p484
gem install bundler --no-rdoc --no-ri
bundle install

#add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8070 -j ACCEPT -m comment --comment "by murano, CloudFoundryUI"'



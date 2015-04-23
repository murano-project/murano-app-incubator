#!/bin/bash
OPENLDAP_IP="$1"
HOST="$2"
DOMAIN="$3"

# parse tld
NAME="`echo "$DOMAIN" | cut -d. -f1`"
TLD="`echo "$DOMAIN" | cut -d. -f2`"

# generate sshkeys with NO PASSWORD 
sudo -u gerrit2 ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# setup gerrit to authenticate from OpenLDAP
sed -e "s/type = OPENID/type = ldap/" -i /home/gerrit2/gerrit_testsite/etc/gerrit.config
sed -e "s,canonicalWebUrl.*,canonicalWebUrl = http://${HOST}:8080," -i /home/gerrit2/gerrit_testsite/etc/gerrit.config
cat << EOF >> /home/gerrit2/gerrit_testsite/etc/gerrit.config
[ldap]
	server = ldap://${OPENLDAP_IP}
 	accountBase = ou=users,dc=${NAME},dc=${TLD}  
 	username =  cn=admin,dc=${NAME},dc=${TLD}
 	password = openstack
 	accountFullName = cn  
EOF

# restart gerrit
sudo -u gerrit2 /home/gerrit2/gerrit_testsite/bin/gerrit.sh restart

# add ssh key to gerrit but need to have a key already there. This needs to be done GUI for noww
# cat ~/.ssh/id_rsa.pub | ssh -i ~/.ssh/id_rsa -p 29418 localhost gerrit set-account --add-ssh-key - gerrit2

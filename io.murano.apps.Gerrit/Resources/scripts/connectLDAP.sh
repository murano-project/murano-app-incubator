#!/bin/bash
OPENLDAP_IP="$1"
HOST="$2"
DOMAIN="$3"

NAME="`echo "$DOMAIN" | cut -d. -f1`"
TLD="`echo "$DOMAIN" | cut -d. -f2`"

echo "configure User" > /tmp/connectldap.out
echo $NAME $TLD $OPENLDAP_IP $HOST >> /tmp/connectldap.out

# setup gerrit
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
sudo -u gerrit2 /home/gerrit2/gerrit_testsite/bin/gerrit.sh restart
sudo -u gerrit2 ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

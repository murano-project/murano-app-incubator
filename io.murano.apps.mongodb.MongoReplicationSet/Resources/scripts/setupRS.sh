#!/bin/bash

# Init the RS

mongo --eval "rs.initiate()"

sleep 10

while [ $# -gt 0 ]
do
 host=$1
 hostname=`echo $host | cut -f1 -d':'`
 ip=`echo $host | cut -f2 -d':'`
 echo "rs.add(\"$hostname\")" >> /tmp/install.log
 mongo --eval "rs.add(\"$hostname\")" >> /tmp/install.log

 shift
done

mongo --eval "rs.status()" >> /tmp/install.log


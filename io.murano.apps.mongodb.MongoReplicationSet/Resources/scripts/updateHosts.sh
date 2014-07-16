#!/bin/bash

while [ $# -gt 0 ]
do
 host=$1
 hostname=`echo $host | cut -f1 -d':'`
 ip=`echo $host | cut -f2 -d':'`

 echo "$ip  $hostname" >> /etc/hosts
 shift
done
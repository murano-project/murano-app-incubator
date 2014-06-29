#!/bin/bash

# Init the RS

mongo --eval "rs.initiate()"

while [ $# -gt 0 ]
do
 mongo --eval "rs.add(\"$1\")"
 shift
done

mongo --eval "rs.status()"


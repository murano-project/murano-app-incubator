#!/bin/bash

mysql --user=root --password=root -e "GRANT ALL PRIVILEGES ON DATABASE $1 to '$2'@'localhost' WITH GRANT OPTION"
mysql --user=root --password=root -e "GRANT ALL PRIVILEGES ON DATABASE $1 to '$2'@'%' WITH GRANT OPTION"

#!/bin/bash

systemctl restart postgresql.service 2>&1
systemctl status postgresql.service | grep Active | awk '{print $2 $3}'

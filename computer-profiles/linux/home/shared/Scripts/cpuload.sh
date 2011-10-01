#!/bin/bash
#echo `uptime` | awk '{ print $4 " " $5 " " $6 " \033[1;31m"$8"\033[1;34m"$9$10}'
echo `uptime` | awk '{ print $9$10$11}'

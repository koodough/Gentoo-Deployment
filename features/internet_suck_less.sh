#!/bin/bash
# internet_suck_less.sh
# Replaces hosts file to block all known ad servers or any malicious sites. Updated weekly.
# http://someonewhocares.org/hosts/hosts

gentoo_commander post_install "curl -o /etc/hosts http://someonewhocares.org/hosts/hosts"
gentoo_commander post_install "
mkdir -p /etc/cron.weekly && 
echo 'curl -o /etc/hosts http://someonewhocares.org/hosts/hosts' >> /etc/cron.weekly/internet_suck_less && 
chmod 775 /etc/cron.weekly/internet_suck_less"

#!/bin/bash

# internet_suck_less.sh
# Replaces hosts file to block all known ad servers or any malicious sites. Updated weelky.
# http://someonewhocares.org/hosts/hosts

gentoo_commander post_install "curl -o /etc/hosts http://someonewhocares.org/hosts/hosts"

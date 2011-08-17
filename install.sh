#!/bin/bash
#Change this file however you want to send the files to the root of the computer that gentoo will be installed on.

echo -ne "\033[1;34mCopy Gentoo Deployment to... ssh\033[1;0m "
read ok;


DIR="$( cd "$( dirname "$0" )" && pwd )"

scp -r "$DIR" "$ok:/";

#Copy SSH id_rsa.pub to authorized keys for a Passwordless login
#cat ~/.ssh/id_rsa.pub | ssh $ok 'cat >> ~/.ssh/authorized_keys'

#Set some lose permission for the bash script to run
ssh $ok "chmod -R 775 '/Gentoo Deployment'" && echo -e "\033[1;31m/Gentoo\ Deployment/gentoo_deployment.sh\033[1;0m" && ssh $ok;

#!/bin/bash

# github.sh
# Will emerge and setup git's basic preferences
#http://en.gentoo-wiki.com/wiki/Git 

#Ask for username

#Ask for email

#Ask for git color

#http://help.github.com/linux-set-up-git/


PACKAGES="$PACKAGES git"


read -p "user.name: " $GITHUB_EMAIL;
read -p "user.email: " $GITHUB_EMAIL;

while true; do
	read -p "Use a Github account? (no): " yn;
	case $yn in
		[Yy]*)	

			read -p "Global github.user: " $github_user;
			read -p "Global github.token: " $github_token;
			gentoo_commander post_install "git config --global user.name $github_user" 
			gentoo_commander post_install "git config --global user.name $github_token" 
			
			break;;
		#[Nn]*)break;;
		#*)	break;;
	esac
done

read -p "Email address for Github: " $GITHUB_EMAIL;
read -p "Email address for Github: " $GITHUB_EMAIL;

#Git
git config --global user.name "Firstname Lastname"
git config --global user.email "your_email@youremail.com"

#Github
git config --global github.user username
git config --global github.token 0123456789yourf0123456789token

#Don't overwrite any ssh keys
#If the keys exists then copy to key_backup_(date)
cd /home/$USERNAME/.ssh/
if [[ -f /home/$USERNAME/.ssh/id_rsa ]]; then
	cp id_rsa* "key_backup_`date +%m-%d-%Y`" && rm id_rsa*;
fi

ssh-keygen -t rsa -C "your_email@youremail.com"

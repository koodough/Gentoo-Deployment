#!/bin/bash
# github.sh
# Will emerge and setup git's basic preferences
#http://en.gentoo-wiki.com/wiki/Git 
#http://help.github.com/linux-set-up-git/


PACKAGES="$PACKAGES git"


read -p "user.name: " $git_user;
read -p "user.email: " $git_email;
gentoo_commander post_install "git config --global user.name $git_user" 
gentoo_commander post_install "git config --global user.email $git_email" 
gentoo_commander post_install "git config color.ui true" 

while true; do
	read -p "Setup a Git for Github? (no): " yn;
	case $yn in
		[Yy]*)	

			#Don't overwrite any ssh keys
			#If the keys exists then copy to key_backup_(date)
			cd /home/$USERNAME/.ssh/
			if [[ -f /home/$USERNAME/.ssh/id_rsa ]]; then
				cp id_rsa* "key_backup_`date +%m-%d-%Y`" #&& rm id_rsa*;
				gentoo_commander post_message "Backed up ssh keys into /home/$USERNAME/.ssh/key_backup_`date +%m-%d-%Y`"
			fi

			read -p "Global github.user: " $github_user;
			read -p "Global github.token: " $github_token;
			read -p "Github email: " $github_email;
			gentoo_commander post_install "git config --global github.user $github_user" 
			gentoo_commander post_install "git config --global github.token $github_token" 
			gentoo_commander post_install "ssh-keygen -t rsa -C $github_email"
			gentoo_commander post_install "ssh -T git@github.com"
			

			break;;
		#[Nn]*)break;;
		#*)	break;;
	esac
done


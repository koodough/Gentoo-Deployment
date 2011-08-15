#!/bin/bash
#Sam Chambers
#Custom Configs by File Tree, AKA Gentoo install custom configs
#Description: This script will compress a folder reprenting a file tree of configs you want to save and also decompress the compressed file and replace only what the compressed file has in its file tree


directory_name="$( cd "$( dirname "$0" )" && pwd )"


pig="$1"
cow="$2"

if [[ $1 ]]; then
	choice=$1;
else

	echo -e "This script will compress a folder representing a file tree of configs you want to save and also decompress the compressed file and add/replace file from that file tree. Great for quickly setting up Gentoo.\n\n 
	Install - Install a root tree\n 
	Lolwut - Dunno"
	read -p ": " choice;

fi
#if [ -z "$PATH_TO_FILE_TREE_FOLDER" ]; then
#	read -e -p "Type the file path of the file tree folder: " PATH_TO_FILE_TREE_FOLDER;
#fi

	function print_step()
	{
		echo -e "\033[32m* \033[1;37m$1 \033[00m"	
	}

	#Compress
	function compress 
	{	
		ROOT_TREE_DIRECTORY="${ROOT_TREE_DIRECTORY:-"/root_dir"}"
		cd "$ROOT_TREE_DIRECTORY";

		print_step "Cleaning $ROOT_TREE_DIRECTORY by removing any .DS_Store, Thumbs.db, and/or ._*"
		find "$ROOT_TREE_DIRECTORY/" -name '.DS_Store' -exec rm -f {} \;
		find "$ROOT_TREE_DIRECTORY/" -name 'Thumbs.db' -type d -exec rm -f {} \;
		find "$ROOT_TREE_DIRECTORY/" -name '._*' -exec rm -f {} \;

		print_step "Compressing file tree"
		cd "$ROOT_TREE_DIRECTORY";
		tar czvf "$ROOT_TREE_DIRECTORY.tar.gz" -C "$ROOT_TREE_DIRECTORY" ./*
	}

	#Install Root Tree
	function install_root_tree
	{
		ROOT_TREE_DIRECTORY="$1"
		ROOT_DIRECTORY="$2"

		if [[ -z  "$ROOT_TREE_DIRECTORY" ]]; then

			read -e -p "Path to root tree folder that you want to compress (/root_dir): " ROOT_TREE_DIRECTORY;
			ROOT_TREE_DIRECTORY=${ROOT_TREE_DIRECTORY:-"/root_dir"}

		fi	
		file="${ROOT_TREE_DIRECTORY%%.*}.tar.gz"
		#If there isn't a tar of the file then create one.
		print_step "Checking to see if the root directory needs to be compressed"
		if [ ! -e "$file" ]; then
			print_step "Compress"
			compress
		else
			print_step "Not need to compress `basename $ROOT_TREE_DIRECTORY`"
		fi
		if [[ -z "$ROOT_DIRECTORY" ]]; then
			read -e -p "Type the file path of your root directory (/): " ROOT_DIRECTORY;
			ROOT_DIRECTORY=${ROOT_DIRECTORY:-"/"}
			print_step "Adding/Replacing files from the archive tree called `basename $ROOT_TREE_DIRECTORY`.tar.gz and replacing any files that is conflicts in $ROOT_DIRECTORY"
			echo "You must need to know what you're replacing. You made the file tree and you will pay for your mistakes after point. OK!"; read;
		fi
		print_step "Expanding and Installing file tree"
		cd "$ROOT_DIRECTORY"
		tar xzfpv "${ROOT_TREE_DIRECTORY%%.*}.tar.gz" -C "$ROOT_DIRECTORY" >&2

		print_step "DONE!"
	}


	#Lolwut
	function lolwut
	{
		echo -e "
		Your Root Directory
		/etc/make.conf
		/etc/screenrc

		Your Archive Tree
		/etc/make.conf
		/etc/screenrc
		/home/shared/awesome_scripts_I_made

		AFTER
		Replaces\tmake.conf
		Replaces\tscreeenrc
		Adds\t\t/home/shared/awesome_scripts_I_made"
	}


	#Do Stuff
	case $choice in
		[Ii]*) install_root_tree;;
		[Ll]*) lolwut;;
		*) install_root_tree "$1" "$2";;
	esac


	

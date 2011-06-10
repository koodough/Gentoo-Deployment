#!/bin/bash
#Sam Chambers
#Custom Configs by File Tree, AKA Gentoo install custom configs
#Description: This script will compress a folder reprenting a file tree of configs you want to save and also decompress the compressed file and replace only what the compressed file has in its file tree


if [ $1 ]; then
	choice=$1;
else

echo -e "This script will compress a folder representing a file tree of configs you want to save and also decompress the compressed file and add/replace file from that file tree. Great for quickly setting up Gentoo.\n\n 1 - Compress a folder\n 2 - Decompress a folder and add/replace config files specified from the compressed file\n 3 - Lolwut?"
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
function stage_1
{	
	cd `dirname $0`;
	read -e -p "Path to root tree folder that you want to compress (/root_dir): " ROOT_TREE_DIRECTORY;
	ROOT_TREE_DIRECTORY=${ROOT_TREE_DIRECTORY:-"/root_dir"}
	
	print_step "Cleaning $ROOT_TREE_DIRECTORY by removing any .DS_Store, Thumbs.db, and/or ._*"
	find $ROOT_TREE_DIRECTORY/ -name '.DS_Store' -exec rm -f {} \;
	find $ROOT_TREE_DIRECTORY/ -name 'Thumbs.db' -type d -exec rm -f {} \;
	find $ROOT_TREE_DIRECTORY/ -name '._*' -exec rm -f {} \;
	
	print_step "Compressing file tree"
	cd "$ROOT_TREE_DIRECTORY";
	tar czvf ../`dirname $0`/`basename $ROOT_TREE_DIRECTORY`.tar.gz -C $ROOT_TREE_DIRECTORY ./*
}

function stage_2
{
read -e -p "Path to root tree folder that you want to compress (/root_dir): " ROOT_TREE_DIRECTORY;
	ROOT_TREE_DIRECTORY=${ROOT_TREE_DIRECTORY:-"/root_dir"}
read -e -p "Type the file path of your root directory (/): " ROOT_DIRECTORY;
	ROOT_DIRECTORY=${ROOT_DIRECTORY:-"/"}
print_step "Adding/Replacing files from the archive tree called `basename $ROOT_TREE_DIRECTORY`.tar.gz and replacing any files that is conflicts in $ROOT_DIRECTORY"
echo "You must need to know what you're replacing. You made the file tree and you will pay for your mistakes after point. OK!"; read;
print_step "Expanding file tree"
cd "$ROOT_DIRECTORY"
tar xzfpv "${ROOT_TREE_DIRECTORY%%.*}.tar.gz" -C "$ROOT_DIRECTORY"
print_step "DONE!"
}

function stage_3
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

stage_$choice

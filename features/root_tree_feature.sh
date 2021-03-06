#!/bin/bash
#Root tree profile
#Root tree Profile feature will install files according to folder structure onto your new gentoo install. Great if you have a lot of custom scripts or custom BASH themes

while true; do
	read -p "Would you like to use a root tree profile? (No)" yn;
	case $yn in
		[Yy]* ) read -e -p "Path to your root tree archive (/root_dir): " ROOT_TREE_DIRECTORY
			ROOT_TREE_DIRECTORY=${ROOT_TREE_DIRECTORY:-"/root_dir"}
			OPTIND=1
			source "../gentoo_root_tree_config.sh \"${ROOT_TREE_DIRECTORY%%.*}.tar.gz\" \"$CHROOT_DIR/\""
			#gentoo_commander pre_chroot "cp -v \"${ROOT_TREE_DIRECTORY%%.*}.tar.gz\" \"$CHROOT_DIR\"";
			#gentoo_commander pre_install "tar xzfpv \"${ROOT_TREE_DIRECTORY%%.*}.tar.gz\" -C \"/\"";
			break;;						
		#[Nn]* ) echo -e "\033[32m\n\nYou must setup your \033[31mmake.conf\033[32m before proceeding any further. \n\033[0mPlease refer to \nhttp://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=5 \nhttp://www.gentoo.org/doc/en/gcc-optimization.xml \nman make.conf\n/usr/share/portage/config/make.conf.example\n\n"; break;;
		#* ) echo -e "\033[32m\n\nYou must setup your \033[31mmake.conf\033[32m before proceeding any further. \n\033[0mPlease refer to \nhttp://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=5 \nhttp://www.gentoo.org/doc/en/gcc-optimization.xml \nman make.conf\n/usr/share/portage/config/make.conf.example\n\n"; break;;
	* ) echo "No root tree profile"
		break;;
	esac
done


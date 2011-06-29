#!/bin/bash
# Gentoo Deployment Version 4
# Created be Koodough and Linuxraptor

#Debug
#set -x

#Print the action the gentoo install script is doing
function print_step
{
	echo -e "\033[32m* \033[1;37m$1 \033[00m"	
}

function print_success_or_failure
{
	RED=$(tput setaf 1)
	GREEN=$(tput setaf 2)
	NORMAL=$(tput sgr0)	
	col=80 # change this to whatever column you want the output to start at

	if [ $1 == 0 ]; then
		printf '%s%*s%s' "$GREEN" $col "[OK]" "$NORMAL";echo "";
	else
		printf '%s%*s%s' "$RED" $col "[FAIL]" "$NORMAL";echo "";
		exit $1
	fi

}


PRE_CHROOT="echo"
PRE_INSTALL="echo"
POST_INSTALL="echo"
MAKE_CONFIG=""
POST_MESSAGE=""

function gentoo_commander
{
	when=$1
	command=$2
	command="${command//\'/\'}";
	command="${command//\"/\\\"}";
	command="${command//\!/\\!}";

	#DEBUG
	#echo "$command"

	case "$when" in
		"make_config")	MAKE_CONFIG="$MAKE_CONFIG $command \n\n";;
		"use_flags")	USE_FLAGS="$USE_FLAGS $command \n\n";;
		"pre_chroot")	PRE_CHROOT="$PRE_CHROOT && $command";;
		"pre_install")	PRE_INSTALL="$PRE_INSTALL && $command";;
		"post_install")	POST_INSTALL="$POST_INSTALL && $command";;
		"post_message")	POST_MESSAGE="$command \n `print_step $POST_MESSAGE`";;
	esac
}

#Not the best way to enumerate all the variables needed
function save_variables
{	
	var_name=(
	ROOT_PARTITION
	BOOT_PARTITION
	CHROOT_DIR
	STAGE3_URL
	PORTAGE_URL
	LOCALTIME
	root_password
	USERNAME
	user_password
	HOSTNAME
	PROFILE
	MAKE_CONFIG
	USE_FLAGS
	PRE_CHROOT
	PRE_INSTALL
	POST_INSTALL
	POST_MESSAGE
	PACKAGES
	);

	#Remove the previous gentoo variables
	print_step "Removing the old gentoo_variables file"
	rm gentoo_variables;

	print_step "Creating the gentoo_variables file"
	for name in ${var_name[@]}; do
		var=`eval echo $\`echo $name\``
		echo "$name=\"$var\"" >> gentoo_variables
	done

	print_step "Done!"
}

#Mount the partition for root and boot for the gentoo installation
function gentoo_mount
{
	#Root Partition
	if [ -n "$ROOT_PARTITION" ]; then
		print_step "Mounting $ROOT_PARTITION to $CHROOT_DIR"
		mount $ROOT_PARTITION $CHROOT_DIR;
	fi

	#Boot Partition
	if [ -n "$BOOT_PARTITION" ]; then
		print_step "Mounting $BOOT_PARTITION to $CHROOT_DIR/boot"
		mount $BOOT_PARTITION $CHROOT_DIR;
	fi
}

#Chroot with all necessary directories mounted
function gentoo_chroot
{
	gentoo_mount;

	mount -t proc none $CHROOT_DIR/proc;
	mount -o bind /dev $CHROOT_DIR/dev;
	mount -o bind /sys $CHROOT_DIR/sys;
	CHROOT_COMMAND=${1:-"/bin/bash"}
	chroot $CHROOT_DIR $CHROOT_COMMAND
}


#It is very important that if there is any way the variables can be validated it would help the user to trouble the issue quicker
function test_variables
{
	#Test Network
	echo -n  "Testing Network"
	ping -c 3 "www.google.com" > /dev/null # try 3 pings and redirect output to /dev/null
	if [ $? -eq 0 ]; then 
		#works	
	fi


	#Test Stage3
	echo -n  "Testing Stage3 URL"
	ping -c 3 $STAGE3_URL > /dev/null # try 3 pings and redirect output to /dev/null
	if [ $? -eq 0 ]; then 
		#Works
	fi

	#Test Portage
	echo -n  "Testing Portage URL"
	ping -c 3 $STAGE3_URL > /dev/null # try 3 pings and redirect output to /dev/null
	if [ $? -eq 0 ]; then 
		#Works
	fi

	#Test Time
	echo -n "Testing Time"
	#Test function
	if [ $? -eq 0 ]; then 
		#Works
	fi

	#gentoo_variables exists
	echo -n "Gentoo variables exists "
	#Test function
	if [ $? -eq 0 ]; then 
		#Works	
	fi
}

#Load Variables, all generated from the questions. Includes both architecture and feature commands
function load_variables
{
	if [ -r /gentoo_variables ];then
		print_step "Gentoo variables loaded"
		source /gentoo_variables
	else
		print_success_or_failure $?;
		echo "Gentoo Variables to not exist!"
	fi

	test_variables;
	if [ $? -eq 0 ]; then 
		echo "Gentoo Variables PASSED"
	else
		echo "Gentoo Variables FAILED"
		exit 1;
	fi
}

###Ask Questions Here###
function setup_arch
{
	#Try to detect arch, if not then give out a selection that are located in the arch directory
	#Pick a computer architecture. The ones in grey are not supported
	#GENTOO_MIRRORS="http://mirrors.cs.wmich.edu/gentoo http://chi-10g-1-mirror.fastsoft.net/pub/linux/gentoo/gentoo-distfiles/ http://gentoo.cites.uiuc.edu/pub/gentoo/"
	$mirror="http://mirrors.cs.wmich.edu/gentoo/releases";
	echo -e "x86, amd64, \033[1;30msparc, ppc, ppc64, alpha, hppa, mips, ia64, arm\033[1;0m"
	read -p "Computer architecture (x86):" architecture;
	architecture=${architecture:-"x86"}
	case $architecture in
		x86|i686)
			STAGE3_URL="$mirror/x86/current-stage3/stage3-i686-20110602.tar.bz2";;
		amd64)
			STAGE3_URL="$mirror/amd64/current-stage3/stage3-amd64-20110602.tar.bz2";;
		*)
			echo "This architecture is not supported in this script yet. Please refer to http://www.gentoo.org/doc/en/handbook/. Your on your own";;
	esac
	PORTAGE_URL="$mirror/snapshots/current/portage-latest.tar.bz2";

}

function setup_features
{
	source ./features/*
}

function ask_questions
{
	echo "Hello, $USERNAME, you are about to install Gentoo on this computer. Please make sure your partitions and file systems are set."
	echo "Ok I have a couple of questions before I install this for you"

	#Date Correct
	#Implement NTP
	date;
	while true; do
		read -p "Date correct?: " yn;
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) htpdate -ds "www.nga.mil" && date && read -p "Is the date and time correct? " yn;;
			* ) echo "Please answer yes or no.";;
		esac

		case $yn in
			[Yy]* ) hwclock -w; break;;
			[Nn]* ) read -p "Update the date using the date MMDDhhmmYYYY syntax (Month, Day, hour, minute and Year):" setdate; date $setdate;;
			* ) echo "Please answer yes or no.";;
		esac
	done

	#Ask for chroot directory
	read -e -p "Chroot directory (/mnt/gentoo):" CHROOT_DIR;
	CHROOT_DIR=${CHROOT_DIR:-"/mnt/gentoo"}
	cd $CHROOT_DIR; pwd;

	#Ask for partitions to install Gentoo. If blank in it will just install in the chroot directory
	cat /proc/partitions && cd /dev/
	echo "Pick your partition for Gentoo. If blank, Gentoo will reside in the chroot directory"
	read -e -p "Root partition: /dev/" ROOT_PARTITION;
	read -e -p "Boot partition: /dev/" BOOT_PARTITION;

	if [ -n "$ROOT_PARTITION" ]; then
		ROOT_PARTITION="/dev/$ROOT_PARTITION";
		echo $ROOT_PARTITION
	fi
	if [ -n "$BOOT_PARTITION" ]; then
		BOOT_PARTITION="/dev/$BOOT_PARTITION";
	fi

	#Computer Name
	read -p "Hostname (localhost): " HOSTNAME;
	HOSTNAME=${HOSTNAME:-"localhost"};

	#ROOT password
	while true; do
		read -s -p "Password for Root:" root_password;echo "";
		read -s -p "Re-enter password for Root:" root_password2;
		if [ "${root_password}" = "${root_password2}" ]; then
			echo "";break;
		else
			echo -e "\n\033[31mFAILURE. PASSWORDS DO NOT MATCH. YOU FAIL SO BAD.\033[0m\n";
		fi
	done

	#USERNAME
	read -p "Username (gentoo):" USERNAME
	USERNAME=${USERNAME:-"gentoo"};
	while true; do
		read -s -p "Password for $USERNAME:" user_password;echo "";
		read -s -p "Re-enter password for $USERNAME:" user_password2;
		if [ "${user_password}" = "${user_password2}" ]; then
			echo "";break;
		else
			echo -e "\n\033[31mFAILURE. PASSWORDS DO NOT MATCH. YOU FAIL SO BAD, $USERNAME.\033[0m\n";
		fi
	done

	#System Profile
	echo "loading profile list...";
	eselect profile list
	while true; do
		read -p "Profile number: " PROFILE;
		case $PROFILE in
			[1-9]|1[1-6])	echo $PROFILE;break;;
		*)	echo "Need to be within 1-16";;
	esac
	done



#Setup Arch to be installed correctly
setup_arch;

#Setup Feature to be installed
setup_features;

#Save variables
save_variables;
}

function run_variable
{
	print_step "Running $1";
	eval $1;
	if [ $? -eq 0 ]; then 
		print_step "$1 complete!"
	else
		print_step "$1 failed!"
		exit 1;
	fi
}
#####################################################################
#INSTALL GENTOO
#####################################################################


#This will install gentoo, only run this once, use the specific stages for troubleshooting
function gentoo_pre_chroot
{
	load_variables;
	test_variables;

	#Create chroot directory and the boot directory in chroot
	if [ ! -d $CHROOT_DIR ]; then
		print_step "Making directory $CHROOT_DIR";
		mkdir -p $CHROOT_DIR;
	fi
	if [ ! -d $CHROOT_DIR/boot ]; then
		print_step "Making directory $CHROOT_DIR/boot";
		mkdir -p $CHROOT_DIR/boot
	fi

	gentoo_mount;

	#Go to gentoo mount point
	cd $CHROOT_DIR;

	#STAGE3
	#Download Stage3
	print_step "Downloading Stage3"
	wget $STAGE3_URL;print_success_or_failure $?;
	print_step "Downloading Stage3 DIGESTS"
	wget $STAGE3_URL.DIGESTS;

	#Checksum Stage3
	print_step "Checksumming Stage3"
	md5sum -c stage3-*.tar.bz2.DIGESTS > /dev/null; print_success_or_failure $?;

	#Unpack Stage 3
	print_step "Unpacking Stage3"
	tar xjpf stage3-*.tar.bz2; print_success_or_failure $?;

	#PORTAGE
	#Download Portage
	print_step "Downloading Portage"
	wget $PORTAGE_URL;print_success_or_failure $?;
	print_step "Downloading Portage md5sum"
	wget $PORTAGE_URL.md5sum;

	#Checksum Portage
	md5sum -c portage-latest.tar.bz2.md5sum > /dev/null; print_success_or_failure $?;

	#Unpack Portage
	print_step "Unpacking Portage"
	tar xjf $CHROOT_DIR/portage-latest.tar.bz2 -C $CHROOT_DIR/usr; print_success_or_failure $?;

	#Copy resolv.conf so the network works in gentoo
	cp -L /etc/resolv.conf $CHROOT_DIR/etc/

	print_step "Copying script and variables to chroot directory"
	cp -v `dirname $0`/`basename $0` $CHROOT_DIR/
	cp -v /gentoo_variables $CHROOT_DIR/gentoo_variables

	#Run pre_chroot variables
	run_variable $PRE_CHROOT;

	gentoo_chroot /`basename $0` "pre_install"
}

function gentoo_pre_install
{
	print_step "--Pre Install--";
	env-update && source /etc/profile
	export PS1="(chroot) $PS1"
	source /gentoo_variables

	#Set password for root
	print_step "Setting password for root";
passwd <<EOF
"${root_password}"
"${root_password}"
EOF

	print_step "Creating user $USERNAME"
	useradd -m -G users,wheel,audio,cdrom,cdrw,floppy,video -s /bin/bash $USERNAME
	print_step "Setting password for $USERNAME"
passwd $USERNAME <<EOF
"${user_password}"
"${user_password}"
EOF

	#Hostname for the computer
	print_step "Setting computer name to $HOSTNAME"
	echo "HOSTNAME=\"$HOSTNAME\"" > /etc/conf.d/hostname
	#DNS Domain for the computer
	echo "dns_domain_lo=\"$HOSTNAME\"" >> /etc/conf.d/net

	#System Profile
	print_step "Setting system profile"
	eselect profile set $PROFILE

	#Making the Portage folder where one can unmask packages and stuff
	#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3&chap=3
	print_step "Setting up portage file structure";
	mkdir -p /etc/portage
	echo -e "#Examples\n#app-office/gnumeric\n#=app-office/gnumeric-1.2.13\n#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3&chap=3\n\n\n" > /etc/portage/package.keywords

	#Set localtime Example America/Chicago
	cp /usr/share/zoneinfo/$LOCALTIME /etc/localtime

	#Backup the /etc/locale.gen just incase in need for reference
	cp /etc/locale.gen /etc/locale.gen.backup
	echo -e "
	# /etc/locale.gen
	en_US ISO-8859-1
	en_US.UTF-8 UTF-8
	" > /etc/locale.gen
	locale-gen

	#Backup the /etc/conf.d/clock just incase in need for reference
	cp /etc/conf.d/clock /etc/conf.d/clock.backup
	echo -e '
	# /etc/conf.d/clock
	CLOCK="local"
	TIMEZONE="'$LOCALTIME'"
	CLOCK_SYSTOHC="no"
	SRM="no"
	ARC="no"
	' > /etc/conf.d/clock

	#Setup eth0
	ln -s /etc/init.d/net.lo /etc/init.d/net.eth0
	rc-update add net.eth0 default

	#Use DHCP
	echo "config_eth0=(\"dhcp\")" >> /etc/conf.d/net

	print_step "emerge --sync --quiet (this should only be run once a day at most)"
	time emerge --sync --quiet

	#Run pre_install
	run_variable $PRE_INSTALL;
}

function gentoo_emerge
{
	env-update && source /etc/profile

	print_step "emerge -uDvN system && emerge -uDvN world"
	time emerge -uDvN system && \
		time emerge -uDvN world && \
		print_step "emerge $PACKAGES" && \
		time emerge $PACKAGES && \
		rc-update add syslog-ng default && \
		rc-update add vixie-cron default && \
		rc-update add sshd default && \
		rc-update add gpm default && \
		rc-update add dbus default && \
		rc-update add udev default && \
		updatedb && \
		run_variable $POST_INSTALL;

	#Post reminders for the user to know about
	echo -e $POST_MESSAGE

	#What is left
	echo -e "1. Setup Kernel\n2. Edit fstab\n3. Setup GRUB if needed."
}

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

echo -e "
	(1) Stage 1 - Download packages\n
	(2) Stage 2 - Configure Gentoo\n
	(3) Stage 3 - Emerge, the long coffee break\n
	(4) Chroot\n
	(5) Configure Gentoo :)\n
	(6) Install Gentoo\n\n";


case $choice in
	1)gentoo_pre_chroot;;
	2)gentoo_pre_install;;
	3)gentoo_emerge;;
	4)gentoo_chroot;;
	5)ask_questions;;
	6)gentoo_pre_chroot && gentoo_pre_install && gentoo_emerge;;
esac


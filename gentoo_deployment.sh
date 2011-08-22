#!/bin/bash
# Gentoo Deployment Version 4
# Created be Koodough and Linuxraptor
# A bash script to simply get gentoo installed on machines, which can be used to understand how gentoo users take preventative measures to avoid bugs (once the script gets more robust enough.


#Debug
#set -x

#Print the action the gentoo install script is doing

directory_name="$( cd "$( dirname "$0" )" && pwd )"

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

#ACKNOWLEDGE_MESSAGE=""
PRE_CHROOT="echo"
PRE_INSTALL="echo"
POST_INSTALL="echo"
MAKE_CONFIG="\n\n"
POST_MESSAGE=""



#gentoo_commander is the star for this Gentoo Deployment to work.
#If your making a feature script this treat gentoo_commander like eval
#Your Command NEEDS to be in QUOTES as well ESCAPED inside the STRING, that ALL.
#Example: gentoo_commander pre_install "echo \"exec ratpoison\" > /home/$USER/.xinitrc";
#Example 2: gentoo_commander pre_install "echo -e \"[Desktop Entry] \\\nType=Application \\\nVersion=1.3.3.7 \\\nEncoding=UTF-8\\\nName=Ratpoison\\\nComment=Minimalistic Window Manager\\\nExec=ratpoison\" > /usr/share/xsessions/ratpoison.desktop\""
function gentoo_commander
{
	#Could be any string in the case list
	when=$1
	#Escaping the code properly. Only method I found to work
	command=$2
	command="${command//\'/\'}";
	command="${command//\"/\\\"}";
	command="${command//\!/\\!}";

	#DEBUG
	#echo "$command"
	

	case "$when" in
		"make_config")	MAKE_CONFIG="$MAKE_CONFIG $command \n";;
		"use_flags")	USE_FLAGS="$USE_FLAGS $command ";;
		"pre_chroot")	PRE_CHROOT="$PRE_CHROOT && $command";;
		"pre_install")	PRE_INSTALL="$PRE_INSTALL && $command";;
		"post_install")	POST_INSTALL="$POST_INSTALL && $command";;
		"post_message")	POST_MESSAGE="`print_step $command`\n$POST_MESSAGE";;
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
	rm "$directory_name/gentoo_variables";

	print_step "Creating the gentoo_variables file"
	print_step "Saving the gentoo_variables in $directory_name/gentoo_variables"
	for name in ${var_name[@]}; do
		var=`eval echo $\`echo $name\``
		echo "$name=\"$var\"" >> "$directory_name/gentoo_variables"
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
	load_variables;

	gentoo_mount;
	print_step "Mounting /proc /dev and /sys to in $CHROOT_DIR"
	mount -t proc none $CHROOT_DIR/proc;
	mount -o bind /dev $CHROOT_DIR/dev;
	mount -o bind /sys $CHROOT_DIR/sys;
	CHROOT_COMMAND=${1:-"/bin/bash"}
	
	print_step "Placing chroot.lock in $CHROOT_DIR$directory_name"
	touch "$CHROOT_DIR$directory_name/chroot.lock" #Dunno if it really is a lock but its the only way I know if the script is in chroot or not.
	
	print_step "Chrooting into $CHROOT_DIR"
	chroot "$CHROOT_DIR" "$CHROOT_COMMAND"
}


#It is very important that if there is any way the variables can be validated it would help the user to trouble the issue quicker

function test_variables
{
	return;

	#Test Network
	echo -n  "Testing Network"
	ping -c 3 "www.google.com" > /dev/null # try 3 pings and redirect output to /dev/null
	if [ $? -eq 0 ]; then 
		#works	
		print_success_or_failure 0;
	fi


	#Test Stage3
	echo -n  "Testing Stage3 URL"
	ping -c 3 $STAGE3_URL > /dev/null # try 3 pings and redirect output to /dev/null
	if [ $? -eq 0 ]; then 
		#Works
		print_success_or_failure 0;
	fi

	#Test Portage
	echo -n  "Testing Portage URL"
	ping -c 3 $STAGE3_URL > /dev/null # try 3 pings and redirect output to /dev/null
	if [ $? -eq 0 ]; then 
		#Works
		print_success_or_failure 0;
	fi

	#Test Time
	echo -n "Testing Time"
	#Test function
	if [ $? -eq 0 ]; then 
		#Works
		print_success_or_failure 0;
	fi

	#Gentoo eselect
	echo -n "Gentoo commend eselect"
	#Test function
	eselect profile list
	if [ $? -eq 0 ]; then 
		#Works	
		print_success_or_failure 0;
	fi

	#Gentoo curl
	echo -n "Gentoo commend curl"
	#Test function
	curl -f --head "http://google.com" &> /dev/null;
	if [ ! $? -eq 0 ]; then 
		echo "Install Curl"
		print_success_or_failure 1;
	fi
}

#Load Variables, all generated from the questions. Includes both architecture and feature commands
function load_variables
{
	if [ -r "$directory_name/gentoo_variables" ];then
		print_step "Gentoo variables loaded"
		source "$directory_name/gentoo_variables"
	else
		ask_questions; #Because you have too!@@@1
	fi

	test_variables;
	if [ $? -eq 0 ]; then 
		echo "Gentoo Variables PASSED"
	else
		echo "Gentoo Variables FAILED"
		exit 1;
	fi
}

#Find the newest stage from the mirror. Could find any better way, because gentoo won't have a stage3_latest link so the script pings the server until it find the lastest portage. Not happy about this GRRR!!!! ME MADDD BLARGH!
function newest_stage
{
	mirror=$1
	#mirror="http://mirrors.cs.wmich.edu/gentoo/releases";
	#mirror="$mirror/x86/current-stage3/stage3-i686-*.tar.bz2";

	for (( i = 0; i < 30; i++ )); do
		stage3_date=$(date -d "$i day ago" +'%Y%m%d')
		host=${mirror/"*"/$stage3_date}
		curl -f --head $host &> /dev/null; 
		if [[ $? -eq 0 ]]; then 
			echo $host;
			#STAGE3_URL=$host
			return 0;
		fi
		#ONLY FOR DEBUGGING. will corrupt gentoo_variables
		#echo "404 $host"
	done
	
	echo "No stage found"
	return 1;
}

###Ask Questions Here###
function setup_arch
{
	#Try to detect arch, if not then give out a selection that are located in the arch directory
	#Pick a computer architecture. The ones in grey are not supported
	#GENTOO_MIRRORS="http://mirrors.cs.wmich.edu/gentoo http://chi-10g-1-mirror.fastsoft.net/pub/linux/gentoo/gentoo-distfiles/ http://gentoo.cites.uiuc.edu/pub/gentoo/"
	mirror="http://mirrors.cs.wmich.edu/gentoo/releases";
	echo -e "x86, i486, amd64, \033[1;30msparc, ppc, ppc64, alpha, hppa, mips, ia64, arm\033[1;0m"
	read -p "Computer architecture (x86):" architecture;
	architecture=${architecture:-"x86"}
	case $architecture in
		x86|i686)
			stage3_filepath="x86/current-stage3/stage3-i686-*.tar.bz2";;
		4|i486|i4*)
			stage3_filepath="x86/current-stage3/stage3-i486-*.tar.bz2";;
		amd64)
			stage3_filepath="amd64/current-stage3/stage3-amd64-*.tar.bz2";;
		*)
			echo "This architecture is not supported in this script yet. Please refer to http://www.gentoo.org/doc/en/handbook/";;
	esac
	STAGE3_URL=`newest_stage "$mirror/$stage3_filepath"`
	print_step "Stage3 URL:$STAGE3_URL";
	PORTAGE_URL="$mirror/snapshots/current/portage-latest.tar.bz2";
	print_step "Portage URL:$PORTAGE_URL"
}

#Open all scripts in ./features/
function setup_features
{
	print_step "Loading features from the $directory_name"

	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b") 
	FILES="$directory_name/features/*"
	for f in $FILES
	do
		source "$f"
	done
	# restore $IFS
	IFS=$SAVEIFS
}

function ask_questions
{
	echo "Hello, $USER, you are about to install Gentoo on this computer. Please make sure your partitions and file systems are set."
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
	mkdir -p $CHROOT_DIR;
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

#After all the features have been sourced add the use flags to MAKE_CONFIG
gentoo_commander make_config "USE=\"$USE_FLAGS\""

#Save variables
save_variables;

#Print any necessary messages that might help
echo -e "Make configs\n$MAKE_CONFIG\n"
echo -e "Use Flags\n$USE_FLAGS\n"
echo -e "Post Messages\n$POST_MESSAGE\n"
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
	#print_step "Checksumming Stage3"
	#md5sum -c stage3-*.tar.bz2.DIGESTS > /dev/null; print_success_or_failure $?;

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
	#print_step "Checksumming Portage"
	#md5sum -c portage-latest.tar.bz2.md5sum > /dev/null; print_success_or_failure $?; Problem is md5sum with output errors if its good or not

	#Unpack Portage
	print_step "Unpacking Portage"
	tar xjf $CHROOT_DIR/portage-latest.tar.bz2 -C $CHROOT_DIR/usr; print_success_or_failure $?;

	#Copy resolv.conf so the network works in gentoo
	cp -L /etc/resolv.conf $CHROOT_DIR/etc/

	print_step "Copying script and variables to chroot directory"
	cp -rv  "$directory_name" "$CHROOT_DIR/"
	##cp -v "$directory_name/gentoo_variables" "$CHROOT_DIR/gentoo_variables"

	#Run pre_chroot variables
	run_variable "$PRE_CHROOT";
	
	#Append to make.conf
	gentoo_commander pre_chroot "echo -e \"$MAKE_CONFIG\" >> $CHROOT_DIR/etc/make.conf"

	
	gentoo_chroot "$directory_name/`basename $0`" "pre_install"
}

function gentoo_pre_install
{
	if [[ ! -e "chroot.lock" ]]; then
		echo -e '\033[1;31mHey! Your not in chroot!! Bad things would have happened... Run step 1.'
		exit 1;
	fi	

	print_step "--Pre Install--";
	env-update && source /etc/profile
	export PS1="(chroot) $PS1"
	source "$directory_name/gentoo_variables"


	#Set password for root
	print_step "Setting password for root";
#NO SPACES OR TAB MARGINS
passwd <<EOF
"${root_password}"
"${root_password}"
EOF

	print_step "Creating user $USERNAME"
	useradd -m -G users,wheel,audio,cdrom,cdrw,floppy,video -s /bin/bash $USERNAME
	print_step "Setting password for $USERNAME"
#NO SPACES OR TAB MARGINS
passwd $USERNAME <<EOF
${user_password}
${user_password}
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
	print_step "Backing up the /etc/conf.d/clock to /etc/conf.d/clock.backup"
	cp /etc/conf.d/clock /etc/conf.d/clock.backup
	echo -e '
	# /etc/conf.d/clock
	CLOCK="UTC"
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

	#print_step "emerge --sync --quiet (this should only be run once a day at most)"
	#time emerge --sync --quiet

	#Run pre_install
	run_variable "$PRE_INSTALL";
}

function gentoo_emerge
{
	env-update && source /etc/profile

	print_step "emerge -uDvN --noreplace system && emerge -uDvN --keep-going --noreplace world"
	time emerge -uDvN --noreplace system && \
		time emerge -uDvN --keep-going --noreplace world && \
		print_step "emerge --keep-going --noreplace $PACKAGES" && \
		time emerge --keep-going --noreplace $PACKAGES && \
		rc-update add syslog-ng default && \
		rc-update add vixie-cron default && \
		rc-update add sshd default && \
		rc-update add gpm default && \
		rc-update add dbus default && \
		rc-update add udev default && \
		updatedb && \
		run_variable "$POST_INSTALL";

	#Post reminders for the user to know about
	echo -e "$POST_MESSAGE"

	#What is left
	echo -e "1. Setup Kernel\n2. Edit fstab\n3. Setup GRUB if needed."
}

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

load_variables;

echo -e "
(1) Step 1 - Configure Gentoo\n
(2) Step 2 - Download packages\n
(3) Step 3 - Configure Gentoo\n
(4) Step 4 - Emerge, the long coffee break\n
(5) Install Gentoo, Step 2,3, and 4\n
(6) Chroot\n";


if [ ! -n "$1" ]; then
	read -p " #" choice
else
	choice=$1;
fi

case $choice in
	1)ask_questions;;
	2)gentoo_pre_chroot;;
	3)gentoo_pre_install;;
	4)gentoo_emerge;;
	5)gentoo_pre_chroot && gentoo_pre_install && gentoo_emerge;;
	6)gentoo_chroot;;
esac


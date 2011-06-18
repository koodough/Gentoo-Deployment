#!/bin/bash
#Gentoo Deployment
#Koodough and Linuxraptor

#Debug
#set -x


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
function print_step
{
	echo -e "\033[32m* \033[1;37m$1 \033[00m"	
}


#Not the best way to emuerate all the variables needed
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
	USER
	user_password
	HOSTNAME
	PROFILE
	PRE_CHROOT
	PRE_INSTALL
	INSTALL
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



PRE_CHROOT="echo"
PRE_INSTALL="echo"
INSTALL=""
POST_INSTALL="echo"
POST_MESSAGE=""
function gentoo_commander
{
	when=$1
	command=$2
	#command=`echo $2 | sed 's/['"'"'"]/\\&/g'`;
	command="${command//\'/\'}";
	command="${command//\"/\\\"}";
	command="${command//\!/\\!}";
	
	#DEBUG
	#echo "$command"
	
	case "$when" in
		"pre_chroot")	PRE_CHROOT="$PRE_CHROOT && $command";;
		"pre_install")	PRE_INSTALL="$PRE_INSTALL && $command";;
		"install")		INSTALL="$INSTALL && $command";;
		"post_install")	POST_INSTALL="$POST_INSTALL && $command";;
		"post_message")	POST_MESSAGE="$command `print_step $POST_MESSAGE`";;
	esac
}

#old function
USE_FLAG="";
function use_flag_recommendation
{
	if [ $1 = "add" ]; then
		USE_FLAG="$USE_FLAG $2";
	fi
	
	if [ $1 = "print" ]; then
		echo -e "\033[33mRecommended use flags for make.conf\033[0m\n"
		echo USE_FLAGS;
	fi
}

#old function. remove it when there is a replacment
function kernel_settings_recommendation
{
	if [ $1 = "add" ]; then
		kernel_settings="$USE_FLAG $2";
	fi
	
	if [ $1 = "print" ]; then
		echo -e "\033[33mRecommended use flags for your kernel\033[0m\n"
		echo kernel_settings;
	fi
}

function test_variables
{
    #Ping
    ping -c 3 $STAGE3_URL > /dev/null # try 3 pings and redirect output to /dev/null
    if [ $? -eq 0 ]; then 
        #code to mount the share
    fi


}



function pre_chroot
{
	#Is the date correct?
	date;
	while true; do
	read -p "Is the date and time correct? " yn;
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


	#Ask for partitions to install Gentoo. If blank in it will just install the the chroot directory
	#List partitions
	cat /proc/partitions && cd /dev/
	echo "Pick your partition for Gentoo. If blank, Gentoo will reside in the chroot directory"
	read -e -p "Path to root partition: /dev/" ROOT_PARTITION;
	read -e -p "Path to boot partition: /dev/" BOOT_PARTITION;
	
	if [ -n "$ROOT_PARTITION" ]; then
		ROOT_PARTITION="/dev/$ROOT_PARTITION";
		echo $ROOT_PARTITION
	fi
	if [ -n "$BOOT_PARTITION" ]; then
		BOOT_PARTITION="/dev/$BOOT_PARTITION";
	fi
	
	
	read -e -p "Path to the chroot directory (/mnt/gentoo):" CHROOT_DIR;
	CHROOT_DIR=${CHROOT_DIR:-"/mnt/gentoo"}
	cd $CHROOT_DIR; pwd;
	

	#I don't know the real name of this kind of package
	while true; do
	read -p "Would you like to use a root tree package? " yn;
	case $yn in
			[Yy]* ) read -e -p "Path to your root tree archive (/gentoo_install_configs): " ROOT_TREE_DIRECTORY
						ROOT_TREE_DIRECTORY=${ROOT_TREE_DIRECTORY:-"/gentoo_install_configs"}
				gentoo_commander pre_chroot "cp -v \"${ROOT_TREE_DIRECTORY%%.*}.tar.gz\" \"$CHROOT_DIR\"";
				gentoo_commander pre_install "tar xzfpv \"${ROOT_TREE_DIRECTORY%%.*}.tar.gz\" -C \"/\"";
				break;;						
			[Nn]* ) echo -e "\033[32m\n\nYou must setup your \033[31mmake.conf\033[32m before proceeding any further. \n\033[0mPlease refer to \nhttp://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=5 \nhttp://www.gentoo.org/doc/en/gcc-optimization.xml \nman make.conf\n/usr/share/portage/config/make.conf.example\n\n"; break;;
			* ) echo "Please answer yes or no.";;
	esac
	done
	
	#Mirrorselect http://en.gentoo-wiki.com/wiki/Mirrorselect
	while true; do
	read -p "Use mirrorselect to choose a mirror, pick the fastest mirror (~7min), or neither? mirror/fast/neither (neither): " yn;
	case $yn in
		[Mm]*)
			gentoo_commander pre_install "mirrorselect -i -r -o >> /etc/make.conf"; break;;
		[Ff]*)
			gentoo_commander pre_install "mirrorselect -s3 -b10 -o -D >> /etc/make.conf"; break;;
		*) echo "Make sure you have a mirror picked your make.conf"; break;;
	esac

	
	#Pick a computer architecture. The ones in grey are not supported
	#GENTOO_MIRRORS="http://mirrors.cs.wmich.edu/gentoo http://chi-10g-1-mirror.fastsoft.net/pub/linux/gentoo/gentoo-distfiles/ http://gentoo.cites.uiuc.edu/pub/gentoo/"
	echo -e "x86, amd64, \033[1;30msparc, ppc, ppc64, alpha, hppa, mips, ia64, arm\033[1;0m"
	read -p "Computer architecture (x86):" architecture;
	architecture=${architecture:-"x86"}
	case $architecture in
		x86|i686)
			STAGE3_URL="http://mirrors.cs.wmich.edu/gentoo/releases/x86/current-stage3/stage3-i686-20110602.tar.bz2";;
		amd64)
			STAGE3_URL="http://mirrors.cs.wmich.edu/gentoo/releases/amd64/current-stage3/stage3-amd64-20110602.tar.bz2";;
		*)
			echo "This architecture is not supported in this script yet. Please refer to http://www.gentoo.org/doc/en/handbook/. Your on your own";;
	esac
	PORTAGE_URL="http://mirrors.cs.wmich.edu/gentoo/releases/snapshots/current/portage-latest.tar.bz2";

}

function pre_install
{
	
	cd /usr/share/zoneinfo
	read -e -p "Localtime (America/Chicago):" LOCALTIME;
	LOCALTIME=${LOCALTIME:-"America/Chicago"}
    cd /
	
	#ROOT
	while true; do
	read -s -p "Password for Root:" root_password;echo "";
	read -s -p "Re-enter password for Root:" root_password2;
		if [ "${root_password}" = "${root_password2}" ]; then
			echo "";break;
		else
			echo -e "\n\033[31mFAILURE. PASSWORDS DO NOT MATCH. YOU FAIL SO BAD.\033[0m\n";
		fi
	done
	
	#USER
	read -p "User for day-to-day use:" USER
	
	while true; do
	read -s -p "Password for $USER:" user_password;echo "";
	read -s -p "Re-enter password for $USER:" user_password2;
		if [ "${user_password}" = "${user_password2}" ]; then
			echo "";break;
		else
			echo -e "\n\033[31mFAILURE. PASSWORDS DO NOT MATCH. YOU FAIL SO BAD, $USER.\033[0m\n";
		fi
	done
	
	#Computer Name
	read -p "Hostname (localhost): " HOSTNAME;
	HOSTNAME=${HOSTNAME:-"localhost"};
	
	#System Profile
	echo "loading profile list...";
	eselect profile list
	
	while true; do
	read -p "Profile number: " PROFILE;
	case $PROFILE in
		[1-9]|1[1-4])	echo $PROFILE;break;;
		*)	echo "Need to be within 1-14";;
	esac
	done
	
	
	
	#++Type of system++#
	STANDARD_PACKAGES="syslog-ng vixie-cron mlocate dhcpcd pciutils hwinfo app-misc/screen sudo eix gentoolkit lafilefixer app-arch/lzop net-misc/openssh net-misc/openssh-blacklist gpm htop powertop latencytop net-misc/htpdate sys-power/acpid"
	DESKTOP_PACKAGES="x11-base/xorg-server xorg-drivers x11vnc synergy"
	GNOME_PACKAGES="gnome x11-themes/gnome-colors-themes dbus www-client/chromium app-admin/gnome-system-tools gparted"
	#KDE_PACKAGES=""
	#SERVER_PACKAGES=""
	#COMPIZ_PACKAGES="x11-apps/fusion-icon x11-wm/emerald dev-python/compizconfig-python beep"
	
	
	while true; do
	echo -e "\n\033[1;33mG\033[34mnome,\033[1;30m KDE, AWESOME, X,\033[36m \033[1;33mN\033[34mone\033[0m"
	read -p "What kind of system do you want? " SYSTEM;
	case $SYSTEM in
			#Gnome
			[Gg]* )	PACKAGES="$PACKAGES $STANDARD_PACKAGES $DESKTOP_PACKAGES $GNOME_PACKAGES" && \
					gentoo_commander pre_install "echo \"exec ck-launch-session gnome-session\" > /root/.xinitrc";
					#gentoo_commander pre_install "echo \"export XDG_MENU_PREFIX=gnome-\" > /root/.xinitrc";
					gentoo_commander pre_install "sed -i \"1i\\\export XDG_MENU_PREFIX=gnome-\" /root/.xinitrc";
					gentoo_commander pre_install "mkdir -p /home/$USER";
                    gentoo_commander pre_install "echo \"exec ck-launch-session gnome-session\" > /home/$USER/.xinitrc";
                    gentoo_commander pre_install "sed -i \"1i\\\export XDG_MENU_PREFIX=gnome-\" /home/$USER/.xinitrc";
					gentoo_commander pre_install "echo \"gnome-base/gnome-session branding\" >> /etc/portage/package.use";
					gentoo_commander pre_install "echo -e \"#Gnome\\\nx11-themes/gnome-colors-themes\\\nx11-themes/gnome-colors-common\\\n\\\n\" >> /etc/portage/package.keywords";
                    gentoo_commander pre_install "echo -e \"#Adobe Flash\\\nwww-plugins/adobe-flash\\\n\\\n\" >> /etc/portage/package.keywords";
					gentoo_commander post_message "Gnome: Helpful use flags for your make.conf -qt4 -kde X dbus gtk gnome";
					break;;
			#None
			[Nn]* ) PACKAGES="$PACKAGES $STANDARD_PACKAGES;"
					break;;
			* ) echo "Please choose one!";;
	esac
	done
	
	#Xorg
	case $SYSTEM in
		[Nn]* );;
			* ) echo -e "\n\033[31m*\033[0m Make sure your have the \"VIDEO_CARDS\" \"INPUT_DEVICES\" set correctly in make.conf\n";
				PACKAGES="$PACKAGES xorg-drivers";;
	esac
	
	###Services###
	#htpdate
	while true; do
		read -p "Would you like htpdate? " yn
		case $yn in
			[Yy]* ) PACKAGES="$PACKAGES htpdate" && \
					read -p "htpdate server (www.nga.mil):" htpdate_server;
					htpdate_server=${htpdate_server:-"www.nga.mil"}
					gentoo_commander pre_install "USE=\"-*\" emerge htpdate"
					gentoo_commander post_install "echo SERVERS=\"$htpdate_server\" >> /etc/conf.d/htpdate"; break;;
			[Nn]* ) echo "" && break;;
			* ) echo "Please answer yes or no.";;
    esac
	done

	
	#Distcc
	while true; do
		read -p "Would you like Distcc? " yn
		case $yn in
			[Yy]* ) PACKAGES="$PACKAGES distcc" && \
			read -p "Distcc servers Example 127.0.0.1 10.0.1.33 10.0.1.34 (127.0.0.1): " DISTCC_HOSTS;
			DISTCC_HOSTS=${DISTCC_HOSTS:-"127.0.0.1"};
			gentoo_commander pre_chroot		"echo 'NOTE: You cannot use -march=native for a client distcc"
			gentoo_commander pre_install	"USE=\"-*\" emerge distcc"
			gentoo_commander pre_install	"/usr/bin/distcc-config --set-hosts \"$DISTCC_HOSTS\""
			CHOST=`cat /etc/make.conf | grep CHOST= | gawk -F\" '{print $2}'`;
			gentoo_commander pre_install	"mkdir -p /usr/lib/distcc/bin/ && cd /usr/lib/distcc/bin/ && rm c++ g++ gcc cc; echo -e '#\!/bin/bash\\n exec /usr/lib/distcc/bin/$CHOST-g${0:$[-2]} \"$@\"' > $CHOST-wrapper; chmod a+x $CHOST-wrapper; ln -s $CHOST-wrapper cc; ln -s $CHOST-wrapper gcc; ln -s $CHOST-wrapper g++; ln -s $CHOST-wrapper c++"	
			gentoo_commander post_message	"Distcc: Add FEATURES=\"distcc\" in make.conf to use in portage"
			gentoo_commander post_message	"Distcc: Change MAKEOPTS=\"-jN\" in make.conf to the number of (distcc servers * 2) + 2. Example: 10 cores is MAKEOPTS=\"-j22\""
			gentoo_commander post_message	"Distcc: When you want to use distcc run export PATH=\"/usr/lib/ccache/bin:/usr/lib/distcc/bin:${PATH}\" or add it to your ~/.bashrc"
			gentoo_commander post_message	"Distcc: For any distcc server, make sure --allow is set correctly in /etc/conf.d/distccd. NOTE: Distcc server will not run during this gentoo install"
			break;;
			[Nn]* ) echo "" && break;;
			* ) echo "Please answer yes or no.";;
    esac
	done
	
	#GRUB
	while true; do
		read -p "Would you like Grub2? " yn
		case $yn in
			[Yy]* ) PACKAGES="$PACKAGES sys-boot/grub sys-boot/os-prober" && \
					gentoo_commander pre_install "echo -e \"#Grub2\\n<sys-boot/grub-9999 **\\nsys-boot/os-prober\" >> /etc/portage/package.keywords"
					gentoo_commander post_install "grep -v rootfs /proc/mounts > /etc/mtab"
					gentoo_commander post_message "Grub: HEY! This script is definitely not installing grub for you. It's too dangerous. Package is install, now you run grub-install"
					break;;
			[Nn]* ) echo "" && break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
	
	#Bash Complete
	while true; do
		read -p "Would you like Bash Tab-completion TO THE NEXT LEVEL? " yn
		case $yn in
			[Yy]* ) PACKAGES="$PACKAGES bash-completion";
			gentoo_commander post_install "echo \"Adding by the Gentoo Install script\" >> /etc/bash/bashrc";
			gentoo_commander post_install "echo \"[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh\" >> /etc/bash/bashrc";
			gentoo_commander post_install "eselect bashcomp enable ssh sh screen mount nmap util-linux man make bash-builtins gentoo iptables lvm tar tcpdump service base findutils; echo \"Added basic bash-completion\""
			gentoo_commander post_message "Bash Completion: bashcomp has nothing enables for tab-completion. Use eselect bashcomp list to find what to enable"
			break;;
			[Nn]* ) echo "" && break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
	
	#AFP
	while true; do
		read -p "Would you like AFP Server? " yn
		case $yn in
			[Yy]* ) PACKAGES="$PACKAGES net-fs/netatalk";
			gentoo_commander post_install "echo -e \"
				\n AFPD_MAX_CLIENTS=50

				\n # Sets the machines' Appletalk name.
				\n ATALK_NAME=`echo ${HOSTNAME}|cut -d. -f1`

				\n # Change this to set the id of the guest user
				\n AFPD_GUEST=nobody
				\n ATALKD_RUN=yes
				\n PAPD_RUN=no
				\n CNID_METAD_RUN=yes
				\n AFPD_RUN=yes
				\n TIMELORD_RUN=no
				\n A2BOOT_RUN=no
				\n # Control whether the daemons are started in the background
				\n ATALK_BGROUND=no

				\n # export the charsets, read form ENV by apps
				\n export ATALK_MAC_CHARSET
				\n export ATALK_UNIX_CHARSET\" > /etc/netatalk/netatalk.conf";
			gentoo_commander post_install "echo \"- -noddp -uamlist uams_randnum.so,uams_dhx.so\" >> /etc/netatalk/afpd.conf";
			gentoo_commander post_install "mkdir -p /etc/avahi/services && echo \"
				<?xml version=\"1.0\" standalone=\"no\"?><!--*-nxml-*-->
				<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\"> 
				<service-group>
				<!-- Customize this to get a different name for your server in the Finder. -->
				<!-- <name replace-wildcards=\"yes\">%h Gentoo AFP Server</name> -->
				<name replace-wildcards=\"yes\">%h</name>
				<service>
				<type>_device-info._tcp</type>
				<port>0</port>
				<!-- Customize this to get a different icon in the Finder. -->
				<txt-record>model=RackMac</txt-record>
				</service>
				<service>
				<type>_afpovertcp._tcp</type>
				<port>548</port>
				</service>
				</service-group>\" >>  /etc/avahi/services/afpd.service"
			gentoo_commander post_install "rc-update add atalk default"
			gentoo_commander post_install "rc-update add avahi-daemon default"
			break;;
			[Nn]* ) echo "" && break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
	
	#Power Managment
	
	#Compiz
}






	









if [ -r /gentoo_variables ];then
###########################
	print_step "Gentoo variables loaded"
	source /gentoo_variables
###########################
fi

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



function gentoo_chroot
{

	gentoo_mount
	
	mount -t proc none $CHROOT_DIR/proc
	mount -o bind /dev $CHROOT_DIR/dev
	CHROOT_COMMAND=${1:-"/bin/bash"}
	chroot $CHROOT_DIR $CHROOT_COMMAND
}



function stage_1
{
print_step "Stage 1";

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
cd $CHROOT_DIR; pwd;

#Download Stage3
print_step "Downloading Stage3"
wget $STAGE3_URL;print_success_or_failure $?;
print_step "Downloading Stage3 DIGESTS"
wget $STAGE3_URL.DIGESTS;

#Checksum Stage3
md5sum -c stage3-*.tar.bz2.DIGESTS

#Unpack Stage 3
print_step "Unpacking Stage3"
tar xjpf stage3-*.tar.bz2
print_success_or_failure $?;



#Download Portage
print_step "Downloading Portage"
wget $PORTAGE_URL;print_success_or_failure $?;
print_step "Downloading Portage md5sum"
wget $PORTAGE_URL.md5sum;

#Checksum Portage
md5sum -c portage-latest.tar.bz2.md5sum

#Unpack Portage
print_step "Unpacking Portage"
tar xjf $CHROOT_DIR/portage-latest.tar.bz2 -C $CHROOT_DIR/usr
print_success_or_failure $?;

#Copy resolv.conf so the network works in gentoo
cp -L /etc/resolv.conf $CHROOT_DIR/etc/

print_step "Copying script and variables to chroot directory"
cp -v `dirname $0`/`basename $0` $CHROOT_DIR/
cp -v /gentoo_variables $CHROOT_DIR/gentoo_variables

############
print_step "Running Pre-chroot variable";
eval $PRE_CHROOT
############
gentoo_chroot /`basename $0` 2

}



function stage_2
{
print_step "Stage 2";
env-update && source /etc/profile
export PS1="(chroot) $PS1"
source /gentoo_variables

#Set password for root
echo "Password for root"
passwd <<EOF
"${root_password}"
"${root_password}"
EOF

#First user for the computer
#read -p "User for day-to-day use:" USER
#echo $USER

#USER
useradd -m -G users,wheel,audio,cdrom,cdrw,floppy,video -s /bin/bash $USER
echo "Password for $USER"
passwd $USER <<EOF
"${user_password}"
"${user_password}"
EOF

#Hostname for the computer
echo "HOSTNAME=\"$HOSTNAME\"" > /etc/conf.d/hostname

#DNS Domain for the computer
echo "dns_domain_lo=\"$HOSTNAME\"" >> /etc/conf.d/net

#System Profile
eselect profile set $PROFILE

#Making the Portage folder where one can unmask packages and stuff
#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3&chap=3
mkdir -p /etc/portage
echo -e "#Examples\n#app-office/gnumeric\n#=app-office/gnumeric-1.2.13\n#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3&chap=3\n\n\n" > /etc/portage/package.keywords



print_step "emerge --sync --quiet (this should only be run once a day at most)"
time emerge --sync --quiet


#############
print_step "Running Pre-install variable";
eval $PRE_INSTALL
#############

#Run itself on stage 3
print_step "Running Stage 3: The Emerge";
`dirname $0`/`basename $0` 3
}


function stage_3
{
print_step "Stage 3";
print_step "Now take a long coffee break"

#Backup the /etc/locale.gen just incase in need for reference
cp /etc/locale.gen /etc/locale.gen.backup
echo -e "
# /etc/locale.gen
en_US ISO-8859-1
en_US.UTF-8 UTF-8
" > /etc/locale.gen
locale-gen

#Set localtime Example America/Chicago
cp /usr/share/zoneinfo/$LOCALTIME /etc/localtime

#Setup eth0
ln -s /etc/init.d/net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default

#Use DHCP
echo "config_eth0=(\"dhcp\")" >> /etc/conf.d/net

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

#Set the correct time
htpdate -ds "www.nga.mil" && hwclock -w


print_step "emerge -uDvN world"
time emerge -uDvN world && \
print_step "emerge $PACKAGES" && \
time emerge $PACKAGES && \
rc-update add syslog-ng default;
rc-update add vixie-cron default;
rc-update add sshd default;
rc-update add gpm default;
rc-update add dbus default;
updatedb;

##############
print_step "Running Post-install variable";
eval $POST_INSTALL
##############

#####################
echo -e $POST_MESSAGE
#####################

echo -e "1. Setup Kernel\n2. Edit fstab\n3. Setup GRUB if needed."
#WHAT IS LEFT TODO net.eth and net.wlan setup, Framebuffer, package.use package.keywords
}










################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

if [ $1 ]; then
	choice=$1;
else
	#Variables that need to be edited within the script
	echo ROOT_PARTITION is $ROOT_PARTITION;
	echo BOOT_PARTITION is $BOOT_PARTITION;
	echo CHROOT_DIR is $CHROOT_DIR;
	#Choose a mirror from http://www.gentoo.org/main/en/mirrors2.xml
	echo $STAGE3_URL;
	echo $PORTAGE_URL;
	echo "Please make sure these variables are correct"; read;


	echo -e "Which stage do you want. I really don't have time for you to thinking about this. If your dumb do stage 1, if your not then maybe choose another one but I am servious. Its your life that your killing. Seconds away from the people that your love, the people you will meet, and second away from the people you will die with. Maybe before you choose a stage, you should plan out your life goals, because there is no afterlife and you, carbon creature, has a chooose to leave a mark on this world or not. However if your this far into this paragraph, chances are you haven't made any goals to bring to the greater good of man kind. Which is ok… if your an ass. My gawd! choose a stage now! I have no sympathy for your ideling thoughts. Choose now, choose now, choose now, choose now.\nStage 1 - Download packages\nStage 2 - Configure Gentoo\nStage 3 - Emerge - the long coffee break\n4 - Chroot\n5 - Configure Gentoo :)\n\n"
	read -p "Stage: " choice;
fi




case $choice in
	1)stage_$choice;;
	2)stage_$choice;;
	3)stage_$choice;;
	4)gentoo_chroot;;
	5)pre_chroot && pre_install && save_variables;;
esac

#
# Initial state
#[ -e $BREAKPOINT ] && choice=`cat $BREAKPOINT | sed 's/^\([0-9]*\).*$/\1/'`
#[ "$choice" = "" ] && choice=1
# Process each function based on the breakpoint
#max_steps=3
#while [ $choice -le $max_steps ]
#do
  #stage_$choice
  #save_break_point
#  choice=`expr $BP + 1`
#done
#[ -e $BREAKPOINT ] && rm -f $BREAKPOINT
# The file which will save the current position in the job
#BREAKPOINT=/mydir/breakpoint

#save_break_point()
#{
#  echo $choice >$BREAKPOINT
#}

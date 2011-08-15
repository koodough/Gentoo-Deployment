#!/bin/bash


#TODO
# Color TODO,Notes, and Alerts like Gentoo
# Add more Gentoo Alt packages
# Find a way to detect the lastest stage3 for the architechure
# Maybe grep this page for the largest file with stage3 in it's name? Regular expressions!
# Test for internet before starting
# Setup up distcc and htpdate early before the real emerging begins
# IMPORTANT have in red of what needs to be done in after a stage - (Ex. setup make.conf file)
# After the stage which then needs the make.conf file show the infomation one would use to set one up. Webpages, commands, tips
# Tips for /etc/fstab
# Could this be parallel?
# Implement mirrorselect
# Print out what you need to know in the beginnging
# Ask if you plan on compiling your own kernel or using genkernel and emerge if necessary.
# Eix a list of kernel sources and ask what kernel they prefer.
# Should follow the Gentoo Guide steps
#Creat a empty file structice and place only files you want to replace on the gentoo OS

#Step 1 - Is date correct?
#Step 2 - Make directory for chroot
#Step 3 - Download Stage3 and Portage
#Step 4 - Move over resolv.conf
#Step 5 - Mount nessessary folder /proc /dev
#Step 6 - Message to setup Make.conf and display infomation important to do so
#Step 7 - Setup root password, User with groups, DNS hostname, hostname, System Profiler
#Step 8 - Ask for Grub2, Gnome/KDE/XFCE,Openbox, User Friendly packages (gentoolkit, app-shells/bash-completion, eix), ACPI
#Step 9 - Emerge... the long coffee break
#Step 10- Setup locale-gen, DHCP, Timezone, htpdate, rc-update necessary packages
#Step 11- Print out the next things they need to do, Kernel, Grub, and fstab. Also mention what needs to be done for maintenance

#Please run this as root. The gentoo handbook was designed to be in a root shell


###########################
source ./gentoo_variables##
###########################

#Variables that need to be edited within the script
echo ROOT_PARTITION is $ROOT_PARTITION;
echo BOOT_PARTITION is $BOOT_PARTITION;
CHROOT_DIR is $CHROOT_DIR;
#Choose a mirror from http://www.gentoo.org/main/en/mirrors2.xml
echo $STAGE3_URL;
echo $PORTAGE_URL;
echo "Please make sure these variables are correct"; read;






function gentoo_chroot
{
#Root Partition
if [ ! -z "$ROOT_PARTITION" ]; then
print_step "Mounting $ROOT_PARTITION to $CHROOT_DIR"
mount $ROOT_PARTITION $CHROOT_DIR;
fi
#Boot Partition
if [ ! -z "$BOOT_PARTITION" ]; then
print_step "Mounting $BOOT_PARTITION to $CHROOT_DIR/boot"
mount $BOOT_PARTITION $CHROOT_DIR;
fi

mount -t proc none $CHROOT_DIR/proc
mount -o bind /dev $CHROOT_DIR/dev
chroot $CHROOT_DIR /bin/bash
}



function stage_1
{

if [ ! -d $CHROOT_DIR ]; then
        print_step "Making directory $CHROOT_DIR";
        mkdir -p $CHROOT_DIR;
fi
if [ ! -d $CHROOT_DIR/boot ]; then
        print_step "Making directory $CHROOT_DIR/boot";
        mkdir -p $CHROOT_DIR/boot
fi

#Mount root partition if there is one
if [ ! -z "$ROOT_PARTITION" ]; then
print_step "Mounting $ROOT_PARTITION to $CHROOT_DIR"
mount $ROOT_PARTITION $CHROOT_DIR;
fi
#Boot root partition if there is one
if [ ! -z "$ROOT_PARTITION" ]; then
print_step "Mounting $BOOT_PARTITION to $CHROOT_DIR/boot"
mount $BOOT_PARTITION $CHROOT_DIR/boot;
fi

#Go to gentoo mount point
cd $CHROOT_DIR; pwd;

#Download Stage3
print_step "Downloading Stage3"
wget $STAGE3_URL;
print_step "Downloading Stage3 DIGESTS"
wget $STAGE3_URL.DIGESTS;

#Checksum Stage3
md5sum -c stage3-*.tar.bz2.DIGESTS

#Unpack Stage 3
print_step "Unpacking Stage3"
tar xjpf stage3-*.tar.bz2


#Download Portage
print_step "Downloading Portage"
wget $PORTAGE_URL;
print_step "Downloading Portage md5sum"
wget $PORTAGE_URL.md5sum;

#Checksum Portage
md5sum -c portage-latest.tar.bz2.md5sum

#Unpack Portage
print_step "Unpacking Portage"
tar xjf $CHROOT_DIR/portage-latest.tar.bz2 -C $CHROOT_DIR/usr

#Copy resolv.conf so the network works in gentoo
cp -L /etc/resolv.conf $CHROOT_DIR/etc/


######
Root_package install

print_step "Copying script to chroot directory"
cp `dirname $0`/`basename $0` $CHROOT_DIR/

############
$pre_chroot#
############
gentoo_chroot
break;
}



function stage_2
{

env-update && source /etc/profile
export PS1="(chroot) $PS1"

#Set password for root
echo "Password for root"
passwd <<EOF
"${root_password}"
"${root_password}"
EOF

#First user for the computer
read -p "User for day-to-day use:" USER
echo $USER

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
}


function stage_3
{
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

#Use DHCP
echo "config_eth0=(\"dhcp\")" >> /etc/conf.d/net
rc-update add net.eth0 default

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
rc-update show


echo -e "1. Setup Kernel\n2. Edit fstab\n3. Setup GRUB if needed."
#WHAT IS LEFT TODO net.eth and net.wlan setup, Framebuffer, package.use package.keywords
}









function print_success_or_failure()
{
	RED=$(tput setaf 1)
	GREEN=$(tput setaf 2)
	NORMAL=$(tput sgr0)	
	
	col=80 # change this to whatever column you want the output to start at

	if $1; then
  		printf '%s%*s%s' "$GREEN" $col "[OK]" "$NORMAL"
	else
  		printf '%s%*s%s' "$RED" $col "[FAIL]" "$NORMAL"
	fi
	echo ""
}

print_success_or_failure $1


function print_step()
{
	echo -e "\033[32m* \033[1;37m$1 \033[00m"	
}


################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
###################################meow#########################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

echo -e "Which stage do you want. I really don't have time for you to thinking about this. If your dumb do stage 1, if your not then maybe choose another one but I am servious. Its your life that your killing. Seconds away from the people that your love, the people you will meet, and second away from the people you will die with. Maybe before you choose a stage, you should plan out your life goals, because there is no afterlife and you, carbon creature, has a chooose to leave a mark on this world or not. However if your this far into this paragraph, chances are you haven't made any goals to bring to the greater good of man kind. Which is ok… if your an ass. My gawd! choose a stage now! I have no sympathy for your ideling thoughts. Choose now, choose now, choose now, choose now.\nStage 1 - Download packages\nStage 2 - Configure Gentoo\nStage 3 - Emerge - the long coffee break\n4 - Chroot\n\n"
read -p "Stage: " BP;


if [ $BP -eq 4 ]; then
	gentoo_chroot
fi


#
# Initial state
#[ -e $BREAKPOINT ] && BP=`cat $BREAKPOINT | sed 's/^\([0-9]*\).*$/\1/'`
#[ "$BP" = "" ] && BP=1
# Process each function based on the breakpoint
max_steps=3
while [ $BP -le $max_steps ]
do
  stage_$BP
  #save_break_point
  BP=`expr $BP + 1`
done
#[ -e $BREAKPOINT ] && rm -f $BREAKPOINT
# The file which will save the current position in the job
#BREAKPOINT=/mydir/breakpoint

#save_break_point()
#{
#  echo $BP >$BREAKPOINT
#}



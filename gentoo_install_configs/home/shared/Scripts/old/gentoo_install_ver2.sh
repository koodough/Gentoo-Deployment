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

#Variables that need to be edited within the script
ROOT_PARTITION="/dev/sda1"; echo ROOT_PARTITION is $ROOT_PARTITION;
CHROOT_DIR="/mnt/gentoo"; echo CHROOT_DIR is $CHROOT_DIR;
#Choose a mirror from http://www.gentoo.org/main/en/mirrors2.xml
#STAGE3_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/releases/amd64/current-stage3/stage3-amd64-20110113.tar.bz2"; echo $STAGE3_URL;
STAGE3_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/releases/x86/current-stage3/stage3-i686-20110503.tar.bz2"; echo $STAGE3_URL;
#STAGE3_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/releases/ppc/current-stage3/stage3-ppc-20110501.tar.bz2"; echo $STAGE3_URL;
PORTAGE_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/snapshots/portage-latest.tar.bz2"; echo $PORTAGE_URL;


echo "Please make sure these variables are correct"; read;




 

function gentoo_chroot
{
if [ ! -z "$ROOT_PARTITION" ]; then
print_step "Mounting $ROOT_PARTITION to $CHROOT_DIR"
mount $ROOT_PARTITION $CHROOT_DIR;
fi
mount -t proc none $CHROOT_DIR/proc
mount -o bind /dev $CHROOT_DIR/dev
chroot $CHROOT_DIR /bin/bash	
	
}

function stage_1
{
	
#Step 1 - Is date correct?
date;
while true; do
read -p "Is the date and time correct? " yn;
case $yn in
        [Yy]* ) break;;
        [Nn]* ) read -p "Update the date using the date MMDDhhmmYYYY syntax (Month, Day, hour, minute and Year):" setdate; sudo date $setdate;;
        * ) echo "Please answer yes or no.";;
esac
done

#Step 2 - Make directory for chroot
if [ ! -d $CHROOT_DIR ]; then
        print_step "Making directory $CHROOT_DIR";
        mkdir -p $CHROOT_DIR;
fi
if [ ! -d $CHROOT_DIR/boot ]; then
        print_step "Making directory $CHROOT_DIR/boot";
        mkdir -p $CHROOT_DIR/boot
fi

#Mount root partition
if [ ! -z "$ROOT_PARTITION" ]; then
print_step "Mounting $ROOT_PARTITION to $CHROOT_DIR"
mount $ROOT_PARTITION $CHROOT_DIR;
fi

#Go to gentoo mount point
cd $CHROOT_DIR; pwd;

#Download Stage3
print_step "Downloading Stage3"
wget $STAGE3_URL;
print_step "Downloading Stage3 DIGESTS"
wget $STAGE3_URL.DIGESTS;

#Checksum to make sure it downloaded properly
md5sum -c stage3-*.tar.bz2.DIGESTS

#Unpack Stage 3
tar xjpf stage3-*.tar.bz2


#Download Portage
print_step "Downloading Portage"
wget $PORTAGE_URL;
print_step "Downloading Portage md5sum"
wget $PORTAGE_URL.md5sum;

#Checksum the download

md5sum -c portage-latest.tar.bz2.md5sum

#Unpack Portage
print_step "Unpacking Portage"
tar xjf $CHROOT_DIR/portage-latest.tar.bz2 -C $CHROOT_DIR/usr

#Copy resolv.conf so the network works in gentoo
cp -L /etc/resolv.conf $CHROOT_DIR/etc/

#SETUP the make.conf!!!!!!
#You do that yourself http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1#book_part1_chap5
#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=2&chap=3
#http://www.gentoo.org/doc/en/gcc-optimization.xml
echo -e "\e[00;32m\n\n\nOk now you must setup your make.conf before proceeding any futher. \nPlease refer to \nhttp://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=5 \nhttp://www.gentoo.org/doc/en/gcc-optimization.xml \nman make.conf\n/usr/share/portage/config/make.conf.example\n\n\e[00m"

cp `dirname $0`/`basename $0` $CHROOT_DIR/
gentoo_chroot
break
}



function stage_2
{

#Variables
PROFILE=""
HOSTNAME=""
DNS_DOMAIN=""
USER=""

#Variables that need to be edited within the script
LOCALTIME="America/Chicago"
PACKAGES="syslog-ng vixie-cron mlocate dhcpcd pciutils hwinfo app-misc/screen sudo eix gentoolkit lafilefixer app-arch/lzop net-misc/openssh net-misc/openssh-blacklist gpm htop powertop latencytop net-misc/htpdate"
MORE_PACKAGES="synergy beep"
GNOME_PACKAGES="gnome x11-themes/gnome-colors-themes dbus www-client/chromium gparted app-admin/gnome-system-tools x11vnc"
EXTRA_PACKAGES="x11-apps/fusion-icon x11-wm/emerald dev-python/compizconfig-python"


env-update && source /etc/profile
export PS1="(chroot) $PS1"

#Set password for root
echo "Password for root"
passwd root

#First user for the computer
read -p "User for day-to-day use:" USER
echo $USER

#USER
useradd -m -G users,wheel,audio,cdrom,cdrw,floppy,video -s /bin/bash $USER
echo "Password for $USER"
passwd $USER

#Hostname for the computer
read -p "HOSTNAME Example tux:" HOSTNAME
echo "HOSTNAME=\"$HOSTNAME\"" > /etc/conf.d/hostname

#DNS Domain for the computer
read -p "DNS Domain Example homenetwork:" DNS_DOMAIN
echo "dns_domain_lo=\"$DNS_DOMAIN\"" >> /etc/conf.d/net

#System Profile
eselect profile list
read -p "Profile number:" PROFILE
eselect profile set $PROFILE

#Making the Portage folder where one can unmask packages and stuff
#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3&chap=3
mkdir -p /etc/portage
echo -e "#Examples\n#app-office/gnumeric\n#=app-office/gnumeric-1.2.13\n#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3&chap=3\n\n\n" > /etc/portage/package.keywords

#Install GRUB2?
while true; do
    read -p "Would you like Grub2? " yn
    case $yn in
        [Yy]* ) echo -e "#Grub2\n<sys-boot/grub-9999 **\nsys-boot/os-prober" >> /etc/portage/package.keywords && PACKAGES="$PACKAGES sys-boot/grub sys-boot/os-prober" && grep -v rootfs /proc/mounts > /etc/mtab && break;;
        [Nn]* ) echo "It's coo" && break;;
        * ) echo "Please answer yes or no.";;
    esac
done

#Install Gnome?
#Maybe detect the profile if they chose Gnome 
while true; do
    read -p "Would you like Gnome? " yn
    case $yn in
        [Yy]* )         echo "exec ck-launch-session gnome-session" > /root/.xinitrc;
                                        sed -i '1i\export XDG_MENU_PREFIX=gnome-' /root/.xinitrc;
                                        echo "exec ck-launch-session gnome-session" > /home/$USER/.xinitrc;
                                        sed -i '1i\export XDG_MENU_PREFIX=gnome-' /home/$USER/.xinitrc;
                                        PACKAGES="$PACKAGES $GNOME_PACKAGES" && \
                                        echo -e "#Gnome\nx11-themes/gnome-colors-themes\nx11-themes/gnome-colors-common\n\n" >> /etc/portage/package.keywords
                                        echo -e "#Adobe Flash\nwww-plugins/adobe-flash\n\n" >> /etc/portage/package.keywords
                                        break;;
        [Nn]* ) echo "No Gnome" && break;;
        * ) echo "Please answer yes or no.";;
    esac
done


#Install htpdate for correct date?
while true; do
    read -p "Would you like htpdate? " yn
    case $yn in
        [Yy]* ) PACKAGES="$PACKAGES htpdate" && break;;
        [Nn]* ) echo "I hope your date is correct lol" && break;;
        * ) echo "Please answer yes or no.";;
    esac
done

#Install Bash Complete?
while true; do
    read -p "Would you like Bash Tab-completion? " yn
    case $yn in
        [Yy]* ) PACKAGES="$PACKAGES bash-completion"
        echo emerge 
        echo "[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh" >> /etc/bash/bashrc
        echo -e "Adding by the Gentoo Install script" >> /etc/bash/bashrc
        
        break;;
        [Nn]* ) echo "" && break;;
        * ) echo "Please answer yes or no.";;
    esac
done

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



#!/bin/bash

#Design to be run once

#Variables
PROFILE=""
HOSTNAME=""
DNS_DOMAIN=""
USER=""

#Variables that need to be edited within the script
LOCALTIME="America/Chicago"
PACKAGES="syslog-ng vixie-cron mlocate dhcpcd pciutils alsa-utils hwinfo app-misc/screen sudo eix gentoolkit lafilefixer app-arch/lzop net-misc/openssh net-misc/openssh-blacklist gpm htop powertop latencytop net-misc/htpdate"
MORE_PACKAGES="synergy beep"
GNOME_PACKAGES="gnome x11-themes/gnome-colors-themes hald dbus www-client/chromium gparted app-admin/gnome-system-tools x11vnc"
#EXTRA_PACKAGES="x11-apps/fusion-icon x11-wm/emerald dev-python/compizconfig-python"


env-update
source /etc/profile
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
echo $HOSTNAME
echo "HOSTNAME=$HOSTNAME" > /etc/conf.d/hostname

#DNS Domain for the computer
read -p "DNS Domain Example homenetwork:" DNS_DOMAIN
echo $DNS_DOMAIN
echo "$DNS_DOMAIN" > /etc/conf.d/net

#System Profile
eselect profile list
read -p "Profile number:" PROFILE
echo $PROFILE
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
        [Yy]* )		echo "exec ck-launch-session gnome-session" > /root/.xinitrc;
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


#TODO
#GET acpi working
#GET Gnome to work


echo "Now take a long coffee break"
echo "emerge --sync --quiet"
emerge --sync --quiet

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


echo "emerge -uDvNe world"
time emerge -uDvNe world && \
echo "emerge $PACKAGES" && \
time emerge $PACKAGES && \
rc-update add syslog-ng default;
rc-update add vixie-cron default;
rc-update add sshd default;
rc-update add gpm default;
rc-update add hald default;
rc-update add dbus default;
updatedb;
rc-update show



echo -e "1. Setup Kernel\n2. Edit fstab\n3. Setup GRUB if needed."
#WHAT IS LEFT TODO net.eth and net.wlan setup, Framebuffer, package.use package.keywords




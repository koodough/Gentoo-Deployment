#!/bin/bash

#Please run this as root. The gentoo handbook was designed to be in a root shell
#The OS running the script must be the same architecture 64bit OS making 64bit gentoo

#Variables that need to be edited within the script
ROOT_PARTITION="/dev/sda1"; echo ROOT_PARTITION is $ROOT_PARTITION;
CHROOT_DIR="/mnt/gentoo"; echo CHROOT_DIR is $CHROOT_DIR;
#Choose a mirror from http://www.gentoo.org/main/en/mirrors2.xml
#STAGE3_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/releases/amd64/current-stage3/stage3-amd64-20110113.tar.bz2"; echo $STAGE3_URL;
STAGE3_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/releases/x86/current-stage3/stage3-i686-20110308.tar.bz2"; echo $STAGE3_URL;
PORTAGE_URL="http://gentoo.cites.uiuc.edu/pub/gentoo/snapshots/portage-latest.tar.bz2"; echo $PORTAGE_URL;


echo "Please make sure these variables are correct"; read;

#Verify the date and time is right
date;
while true; do
    read -p "Is the date and time correct? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) read -p "Update the date using the date MMDDhhmmYYYY syntax (Month, Day, hour, minute and Year):" sedate; sudo date $setdate;;
        * ) echo "Please answer yes or no.";;
    esac
done

#Make sure CHROOT_DIR and CHROOT_DIR boot directory exist and if not create them
if [ ! -d $CHROOT_DIR ]; then
        echo "Making directory $CHROOT_DIR";
        mkdir -p $CHROOT_DIR;
fi
if [ ! -d $CHROOT_DIR/boot ]; then
        echo "Making directory $CHROOT_DIR/boot"
        mkdir -p $CHROOT_DIR/boot
fi


#Mount root partition
echo "Mounting $ROOT_PARTITION to $CHROOT_DIR";
mount $ROOT_PARTITION $CHROOT_DIR;

#Go to gentoo mount point
cd $CHROOT_DIR; pwd;

#Download Stage3
echo "Downloading Stage3"
wget $STAGE3_URL;
echo "Downloading Stage3 DIGESTS"
wget $STAGE3_URL.DIGESTS;

#Checksum to make sure it downloaded properly
md5sum -c stage3-*.tar.bz2.DIGESTS

#Unpack Stage 3
tar xjpf stage3-*.tar.bz2


#Download Portage
echo "Downloading Portage"
wget $PORTAGE_URL;
echo "Downloading Portage md5sum"
wget $PORTAGE_URL.md5sum;

#Checksum the download

md5sum -c portage-latest.tar.bz2.md5sum

#Unpack Portage
echo "Unpacking Portage"
tar xjf $CHROOT_DIR/portage-latest.tar.bz2 -C $CHROOT_DIR/usr

#Copy resolv.conf so the network works in gentoo
cp -L /etc/resolv.conf $CHROOT_DIR/etc/

#SETUP the make.conf!!!!!!
#You do that yourself http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1#book_part1_chap5
#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=2&chap=3
#http://www.gentoo.org/doc/en/gcc-optimization.xml
echo -e "\n\n\nOk now you must setup your make.conf before proceeding any futher. \nPlease refer to \nhttp://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=5 \nhttp://www.gentoo.org/doc/en/gcc-optimization.xml \nman make.conf\n/usr/share/portage/config/make.conf.example\n\n"

mount -t proc none $CHROOT_DIR/proc
mount -o bind /dev $CHROOT_DIR/dev
chroot $CHROOT_DIR /bin/bash


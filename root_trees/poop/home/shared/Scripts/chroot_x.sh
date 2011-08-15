#!/bin/bash

CHROOT=/mnt/ubuntu

cd $CHROOT
mount --bind /dev 		$CHROOT/dev
mount --bind /sys 		$CHROOT/sys
mount --bind /proc 		$CHROOT/proc
#X
mount -t devpts none 		$CHROOT/dev/pts
mount --bind /tmp 		$CHROOT/tmp
mount --bind /lib/modules	$CHROOT/lib/modules

#Sound
mount --bind /var/run/dbus 	$CHROOT/var/run/dbus

cp -L /etc/resolv.conf 	$CHROOT/etc/resolv.conf

chroot $CHROOT

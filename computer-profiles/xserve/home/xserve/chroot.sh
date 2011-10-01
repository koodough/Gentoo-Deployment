#Run this script if there was a reboot in the process of setting up Gentoo
CHROOT_DIR="/diskless/10.0.1.91"; echo CHROOT_DIR is $CHROOT_DIR;

mount -t proc none $CHROOT_DIR/proc
mount -o bind /dev $CHROOT_DIR/dev
chroot $CHROOT_DIR /bin/bash

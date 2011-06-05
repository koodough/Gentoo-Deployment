#Run this script if there was a reboot in the process of setting up Gentoo
ROOT_PARTITION="/dev/sdb7"; echo ROOT_PARTITION is $ROOT_PARTITION;
CHROOT_DIR="/mnt/gentoo"; echo CHROOT_DIR is $CHROOT_DIR;

echo "Mounting $ROOT_PARTITION to $CHROOT_DIR";
mount $ROOT_PARTITION $CHROOT_DIR;

mount -t proc none $CHROOT_DIR/proc
mount -o bind /dev $CHROOT_DIR/dev
chroot $CHROOT_DIR /bin/bash
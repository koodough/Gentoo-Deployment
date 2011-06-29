#!/bin/bash
#GRUB2

PACKAGES="$PACKAGES sys-boot/grub sys-boot/os-prober";
gentoo_commander pre_install "echo -e \"#Grub2\\n<sys-boot/grub-9999 **\\nsys-boot/os-prober\" >> /etc/portage/package.keywords"
gentoo_commander post_install "grep -v rootfs /proc/mounts > /etc/mtab"
gentoo_commander post_message "Grub: HEY! This script is definitely not installing grub for you. It's too dangerous. Package is install, now you run grub-install"

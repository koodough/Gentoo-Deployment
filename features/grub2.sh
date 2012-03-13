#!/bin/bash
#GRUB2
#http://en.gentoo-wiki.com/wiki/Grub2

PACKAGES="$PACKAGES sys-boot/grub:2 sys-boot/os-prober";
gentoo_commander pre_install "echo \"sys-boot/grub:2\" >> /etc/portage/package.accept_keywords"
gentoo_commander pre_install "echo \"sys-boot/grub:2\" >> /etc/portage/package.unmask"
gentoo_commander post_install "grep -v rootfs /proc/mounts > /etc/mtab"
gentoo_commander post_install "grub2-mkconfig -o /boot/grub2/grub.cfg"
gentoo_commander post_message "Grub: HEY! This script is definitely not installing grub for you. It's too dangerous. Package is install, now you run a command something like this in the 
gentoo root\n\ngrub-install --boot-directory=/$ROOT_PARTITION"

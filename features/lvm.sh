#!/bin/bash
#LVM
#Logical Volume Management package and added to rc-update

PACKAGES="$PACKAGES sys-fs/lvm2";

gentoo_commander post_install "rc-update add lvm boot"

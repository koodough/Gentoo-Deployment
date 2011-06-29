#!/bin/bash
#LVM
PACKAGES="$PACKAGES sys-fs/lvm2";

gentoo_commander post_install "rc-update add lvm boot"

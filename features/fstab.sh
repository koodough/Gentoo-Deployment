#!/bin/bash
# fstab.sh
# Overwrites the /etc/fstab with one that works.
# http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=8
# https://wiki.archlinux.org/index.php/Fstab


#UUID_ROOT variable set
eval "UUID_ROOT=\"`blkid -o export $ROOT_PARTITION | head -1`\""

eval "`blkid -o export $ROOT_PARTITION | tail -1`"
UUID_ROOT_FILESYSTEM=$TYPE

#There has to be a root /! Trees need roots and babies have them.
ROOT="$UUID_ROOT 	/ 		$UUID_ROOT_FILESYSTEM 	noatime         0 1"

#UUID_BOOT variable set
eval "UUID_BOOT=\"`blkid -o export $BOOT_PARTITION | head -1`\""

eval "`blkid -o export $BOOT_PARTITION | tail -1`"
UUID_BOOT_FILESYSTEM=$TYPE

if [[ -n "$UUID_BOOT" ]] ; then
	BOOT="$UUID_BOOT 	/boot 	$UUID_BOOT_FILESYSTEM 	noauto,noatime	1 2"
fi

eval "`blkid -o export | grep swap`"
SWAP_PARTITION=$TYPE

#If there is a swap add it to the fstab
if [[ -n "$SWAP_PARTITION" ]] ; then
	SWAP="$SWAP_PARTITION		none		swap		sw		0 0"
fi


#Info blah blah
gentoo_commander pre_install "echo -e \"
\n# /etc/fstab: static file system information.
\n#
\n# noatime turns off atimes for increased performance (atimes normally aren't 
\n# needed); notail increases performance of ReiserFS (at the expense of storage 
\n# efficiency).  It's safe to drop the noatime options if you want and to 
\n# switch between notail / tail freely.
\n#
\n# The root filesystem should have a pass number of either 0 or 1.
\n# All other filesystems should have a pass number of 0 or greater than 1.
\n#
\n# See the manpage fstab(5) for more information.
\n#
\n# <fs>			<mountpoint>	<type>		<opts>		<dump/pass>
\n
\n# NOTE: If your BOOT partition is ReiserFS, add the notail option to opts.
\n
\n \" > /etc/fstab"

#Dinner
gentoo_commander pre_install  "echo -e \"
\n$ROOT
\n$BOOT
\n$SWAP 
\" > /etc/fstab"

gentoo_commander post_message "Check your /etc/fstab to see if it is correct."

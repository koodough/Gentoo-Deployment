#!/bin/bash
#Setups the fastest mirrors for gentoo

gentoo_commander pre_install	"USE=\"-*\" emerge mirrorselect"

while true; do
	read -p "Use mirrorselect to choose a mirror, pick the fastest mirror (~7min), or neither? mirror/fast/neither (neither): " yn;
	case $yn in
		[Mm]*)	gentoo_commander pre_install "mirrorselect -i -r -o >> /etc/make.conf"; break;;
		[Ff]*)	gentoo_commander pre_install "mirrorselect -s3 -b10 -o -D >> /etc/make.conf"; break;;
		*)	echo "Make sure you have a mirror picked your make.conf"; break;;
	esac
done

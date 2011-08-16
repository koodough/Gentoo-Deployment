#!/bin/bash
# Distcc
# Installs Distcc before all the packages are installed in emerge so that the computer can share it works off to other distcc servers.
#Set CHOST

### HEY!!!
# Distcc needs permission to access /dev/null


case $architecture in
		x86|i686)
			CHOST="i686-pc-linux-gnu";;
		amd64)
			CHOST="x86_64-pc-linux-gnu";;
		*)
			CHOST=`cat /etc/make.conf | grep CHOST= | awk -F\" '{print $2}'`;
esac


PACKAGES="$PACKAGES distcc" && \
read -p "Distcc servers Example 127.0.0.1 10.0.1.33 10.0.1.34 (127.0.0.1): " DISTCC_HOSTS;
DISTCC_HOSTS="${DISTCC_HOSTS:-'127.0.0.1'}";
gentoo_commander pre_chroot		"echo 'NOTE: You cannot use -march=native for a client distcc"
gentoo_commander pre_install	"USE=\"-*\" emerge distcc"
gentoo_commander pre_install	"/usr/bin/distcc-config --set-hosts $DISTCC_HOSTS"
gentoo_commander pre_install	"mkdir -p /usr/lib/distcc/bin/ && cd /usr/lib/distcc/bin/ && rm c++ g++ gcc cc; echo -e '#\!/bin/bash\\n exec /usr/lib/distcc/bin/$CHOST-g${0:$[-2]} \"$@\"' > $CHOST-wrapper; chmod a+x $CHOST-wrapper; ln -s $CHOST-wrapper cc; ln -s $CHOST-wrapper gcc; ln -s $CHOST-wrapper g++; ln -s $CHOST-wrapper c++"	
gentoo_commander make_config	"Distcc: Add FEATURES=\"distcc\" in make.conf to use in portage"
gentoo_commander post_message	"Distcc: Change MAKEOPTS=\"-jN\" in make.conf to the number of (distcc servers * 2) + 2. Example: 10 cores is MAKEOPTS=\"-j22\""
gentoo_commander post_message	"Distcc: When you want to use distcc run export PATH=\"/usr/lib/ccache/bin:/usr/lib/distcc/bin:${PATH}\" or add it to your ~/.bashrc"
gentoo_commander post_message	"Distcc: For any distcc server, make sure --allow is set correctly in /etc/conf.d/distccd. NOTE: Distcc server will not run during this gentoo install"

#!/bin/bash
# Makeconf
# Automatic make.conf! Configures CFLAGS, CHOST, MAKEOPTS, Parallel-fetch, and licenses  This script uses equivalent March native to produce the CFLAGS. This is terrific for if you want an optimized computer and also be able to use distcc as march native WILL break distcc if used.

#CFLAGS
echo 'int main(){return 0;}' > test.c 
gcc -v -Q -march=native -O2 test.c -o test &> test.config 
rm test.c test
GEN_OPTS=`cat test.config | awk '{ printf "%s", $0 }' | awk -Ftest.c '{ print $2 }' `
rm test.config
APPEND_OPTS=" -Ofast -pipe -mno-tls-direct-seg-refs"
OPTIMIZATIONS="$GEN_OPTS $APPEND_OPTS"
gentoo_commander make_config "#CFLAGS equivalent to -march=native"
gentoo_commander make_config "CFLAGS=\"$OPTIMIZATIONS\""
gentoo_commander make_config "CXXFLAGS=\"\$\{CFLAGS\}\""
gentoo_commander post_message "NOTE: March native CFLAGS are appended to your /etc/make.conf, appending your previous CFLAGS"


#CHOST
case $architecture in
	x86|i686)
		CHOST="i686-pc-linux-gnu";;
	4|i486)
		CHOST="i486-pc-linux-gnu";;
	amd64)
		CHOST="x86_64-pc-linux-gnu";;
	*)
		echo "This architecture is not supported in this script yet. Please refer to http://www.gentoo.org/doc/en/handbook/";;
esac
gentoo_commander make_config "CHOST=\"$CHOST\""

#MAKEOPTS
#Number of CPUs
CPU=`ls -1 /sys/class/cpuid/ | wc -l`
#Recommended settings are the number of CPUs used to compile emerge plus ones
MAKEOPTS="-j$(($CPU + 1))"
gentoo_commander make_config "MAKEOPTS=\"$MAKEOPTS\""

#Parallel-fetch
gentoo_commander make_config "FEATURES=\"${FEATURES} parallel-fetch\""
#INPUT_DEVICES for mouse, keyboard, and trackpad
gentoo_commander make_config "INPUT_DEVICES=\"evdev synaptics\""

#ACCEPT_LICENSE. ACCEPT EVERytING!
read -p "Accepted software licences (everything) ACCEPT_LICENSE=" ACCEPT_LICENSE;
ACCEPT_LICENSE=${ACCEPT_LICENSE:-"*"}
gentoo_commander make_config "ACCEPT_LICENSE=\"$ACCEPT_LICENSE\""


#VIDEO_CARDS. Don't know how to determine video card
gentoo_commander make_config "#VIDEO_CARDS=\"nouveau\""
gentoo_commander make_config "#VIDEO_CARDS=\"intel\""
gentoo_commander make_config "#VIDEO_CARDS=\"nvidia\""
gentoo_commander make_config "#VIDEO_CARDS=\"radeon\""
gentoo_commander make_config "#VIDEO_CARDS=\"ati\""

#Language. For now its english
gentoo_commander make_config "LINGUAS=\"en\""


#!/bin/bash

# March native
# Out all the flags march native would use for compiling. This is terrific for using distcc because using march native WILL break distcc usage.


echo 'int main(){return 0;}' > test.c 
gcc -v -Q -march=native -O2 test.c -o test &> test.config 
rm test.c test
GEN_OPTS=`cat test.config | awk '{ printf "%s", $0 }' | awk -Ftest.c '{ print $2 }' `
rm test.config
APPEND_OPTS=" -auxbase -O2 -pipe -fomit-frame-pointer -mno-tls-direct-seg-refs"
OPTIMIZATIONS="$GEN_OPTS $APPEND_OPTS"

 
gentoo_commander pre_install "echo -e \"\n\n#CFLAGS equivalent to -march=native\" >> /etc/make.conf"
gentoo_commander pre_install "echo CFLAGS=\"$OPTIMIZATIONS\" >> /etc/make.conf"
gentoo_commander post_message "NOTE: March native CFLAGS are appended to your /etc/make.conf, overriding your previous CFLAGS"

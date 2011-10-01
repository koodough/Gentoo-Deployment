#!/bin/bash

LOCATION="/tftpboot/diskless"
IP="10.0.1.9"

read -p "Is the date and time correct? " yn;

i=2
while [ $i -le 8 ]
do

mkdir 	$LOCATION/$IP$i/home
mkdir 	$LOCATION/$IP$i/dev
mkdir 	$LOCATION/$IP$i/proc
mkdir 	$LOCATION/$IP$i/tmp
mkdir 	$LOCATION/$IP$i/mnt
chmod a+w $LOCATION/$IP$i/tmp
mkdir 	$LOCATION/$IP$i/mnt/.initd
mkdir 	$LOCATION/$IP$i/root
mkdir 	$LOCATION/$IP$i/sys
mkdir 	$LOCATION/$IP$i/var
mkdir 	$LOCATION/$IP$i/var/empty
mkdir 	$LOCATION/$IP$i/var/lock
mkdir 	$LOCATION/$IP$i/var/log
mkdir 	$LOCATION/$IP$i/var/run
mkdir 	$LOCATION/$IP$i/var/spool
mkdir 	$LOCATION/$IP$i/usr
mkdir 	$LOCATION/$IP$i/opt

  i=`expr $i + 1`
done


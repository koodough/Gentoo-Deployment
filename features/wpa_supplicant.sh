#!/bin/bash

# wpa_supplicant.sh
# Basic setup to get wifi working with wpa_supplicant
# http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=4&chap=4


PACKAGES="net-wireless/wpa_supplicant"
gentoo_commander use_flags 
gentoo_commander post_install "echo modules=\"wpa_supplicant\" >> /etc/conf.d/net"
gentoo_commander post_install "echo \"config_wlan0=(\"dhcp\")\" >> /etc/conf.d/net"
gentoo_commander post_message "Please edit /etc/conf.d/net and set your device for wpa_supplicant. Visit http://www.gentoo.org/doc/en/handbook/handbook-x86.xml for help"

#!/bin/bash
#AFP

PACKAGES="$PACKAGES net-fs/netatalk";
gentoo_commander post_install "mkdir -p /etc/netatalk"
gentoo_commander post_install "echo -e \"
\n AFPD_MAX_CLIENTS=50

\n # Sets the machines' Appletalk name.
\n ATALK_NAME=`echo ${HOSTNAME}|cut -d. -f1`

\n # Change this to set the id of the guest user
\n AFPD_GUEST=nobody
\n ATALKD_RUN=yes
\n PAPD_RUN=no
\n CNID_METAD_RUN=yes
\n AFPD_RUN=yes
\n TIMELORD_RUN=no
\n A2BOOT_RUN=no
\n # Control whether the daemons are started in the background
\n ATALK_BGROUND=no

\n # export the charsets, read form ENV by apps
\n export ATALK_MAC_CHARSET
\n export ATALK_UNIX_CHARSET\" > /etc/netatalk/netatalk.conf";

gentoo_commander post_install "echo \"- -noddp -uamlist uams_randnum.so,uams_dhx.so\" >> /etc/netatalk/afpd.conf";

gentoo_commander post_install "mkdir -p /etc/avahi/services && echo \"
<?xml version=\"1.0\" standalone=\"no\"?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\"> 
<service-group>
<!-- Customize this to get a different name for your server in the Finder. -->
<!-- <name replace-wildcards=\"yes\">%h Gentoo AFP Server</name> -->
<name replace-wildcards=\"yes\">%h</name>
<service>
<type>_device-info._tcp</type>
<port>0</port>
<!-- Customize this to get a different icon in the Finder. -->
<txt-record>model=RackMac</txt-record>
</service>
<service>
<type>_afpovertcp._tcp</type>
<port>548</port>
</service>
</service-group>\" >>  /etc/avahi/services/afpd.service"
gentoo_commander post_install "rc-update add atalk default"
gentoo_commander post_install "rc-update add avahi-daemon default"

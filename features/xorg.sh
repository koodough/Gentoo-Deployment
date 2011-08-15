#!/bin/bash
#Xorg

#++Type of system++#
STANDARD_PACKAGES="syslog-ng vixie-cron mlocate dhcpcd pciutils hwinfo app-misc/screen sudo eix gentoolkit lafilefixer app-arch/lzop net-misc/openssh net-misc/openssh-blacklist gpm htop powertop latencytop net-misc/htpdate sys-power/acpid"
DESKTOP_PACKAGES="x11-base/xorg-server xorg-drivers x11vnc synergy"
GNOME_PACKAGES="gnome x11-themes/gnome-colors-themes dbus www-client/chromium app-admin/gnome-system-tools gparted"
#KDE_PACKAGES=""
#SERVER_PACKAGES=""
#COMPIZ_PACKAGES="x11-apps/fusion-icon x11-wm/emerald dev-python/compizconfig-python beep"

while true; do
	echo -e "\n\033[1;33mG\033[34mnome,\033[1;30m KDE, AWESOME, X,\033[36m \033[1;33mN\033[34mone\033[0m"
	read -p "What kind of system do you want? " SYSTEM;
	case $SYSTEM in
		#Gnome
		[Gg]* )	PACKAGES="$PACKAGES $STANDARD_PACKAGES $DESKTOP_PACKAGES $GNOME_PACKAGES" && \
		gentoo_commander pre_install "echo \"exec ck-launch-session gnome-session\" > /root/.xinitrc";
		#gentoo_commander pre_install "echo \"export XDG_MENU_PREFIX=gnome-\" > /root/.xinitrc";
		gentoo_commander pre_install "sed -i \"1i\\\export XDG_MENU_PREFIX=gnome-\" /root/.xinitrc";
		gentoo_commander pre_install "mkdir -p /home/$USER";
		gentoo_commander pre_install "echo \"exec ck-launch-session gnome-session\" > /home/$USER/.xinitrc";
		gentoo_commander pre_install "sed -i \"1i\\\export XDG_MENU_PREFIX=gnome-\" /home/$USER/.xinitrc";
		gentoo_commander pre_install "echo \"gnome-base/gnome-session branding\" >> /etc/portage/package.use";
		gentoo_commander pre_install "echo -e \"#Gnome\\\nx11-themes/gnome-colors-themes\\\nx11-themes/gnome-colors-common\\\n\\\n\" >> /etc/portage/package.keywords";
		gentoo_commander pre_install "echo -e \"#Adobe Flash\\\nwww-plugins/adobe-flash\\\n\\\n\" >> /etc/portage/package.keywords";
		gentoo_commander use_flags "-qt4 -kde X dbus gtk gnome";
		gentoo_commander post_message "Gnome: Use flags for your make.conf -qt4 -kde X dbus gtk gnome";
		break;;
		#None
		[Nn]* ) PACKAGES="$PACKAGES $STANDARD_PACKAGES;"; break;;
		* ) echo "Please choose one!";;
	esac
done

#Xorg
case $SYSTEM in
	[Nn]* );;
	* ) echo -e "\n\033[31m*\033[0m Make sure your have the \"VIDEO_CARDS\" \"INPUT_DEVICES\" set correctly in make.conf\n";
	PACKAGES="$PACKAGES xorg-drivers";;
esac


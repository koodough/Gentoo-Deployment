#!/bin/bash
#Xorg
#Installs Xorg with the choice of Gnome or Xmonad

#++Type of system++#
STANDARD_PACKAGES="syslog-ng app-admin/sysstat sys-process/lsof vixie-cron mlocate dhcpcd pciutils hwinfo app-misc/screen sudo eix gentoolkit lafilefixer app-arch/lzop net-misc/openssh net-misc/openssh-blacklist gpm htop powertop latencytop net-misc/htpdate sys-power/acpid"
DESKTOP_PACKAGES="x11-base/xorg-server xorg-drivers x11vnc synergy"
GNOME_PACKAGES="gnome x11-themes/gnome-colors-themes dbus www-client/chromium app-admin/gnome-system-tools gparted"
#KDE_PACKAGES=""
#SERVER_PACKAGES=""
#COMPIZ_PACKAGES="x11-apps/fusion-icon x11-wm/emerald dev-python/compizconfig-python beep"

while true; do
	echo -e "\n\033[1;33mG\033[34mnome,\033[30m KDE,\033[1;33m R\033[34matpoison,\033[30m AWESOME,\033[1;33m X\033[34mmonad,\033[36m \033[1;33mN\033[34mone\033[0m"
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
		# I really don't know why this works but the \\\n is the only way I could get the file to have returns.
		gentoo_commander pre_install "echo -e \"#Gnome\\\nx11-themes/gnome-colors-themes\\\nx11-themes/gnome-colors-common\\\n\\\n\" >> /etc/portage/package.keywords";
		gentoo_commander pre_install "echo -e \"#Adobe Flash\\\nwww-plugins/adobe-flash\\\n\\\n\" >> /etc/portage/package.keywords";
		gentoo_commander use_flags "-qt4 -kde X dbus jpeg gtk gnome";
		gentoo_commander post_message "Gnome: Use flags for your make.conf -qt4 -kde X dbus gtk gnome";
		break;;
		[Rr]* ) PACKAGES="$PACKAGES ratpoison"; 
		gentoo_commander pre_install "echo \"exec ratpoison\" > /root/.xinitrc";
		gentoo_commander pre_install "mkdir -p /home/$USER";
		gentoo_commander pre_install "echo \"exec ratpoison\" > /home/$USER/.xinitrc";	
		gentoo_commander pre_install "echo -e \"[Desktop Entry] \\\nType=Application \\\nVersion=1.3.3.7 \\\nEncoding=UTF-8\\\nName=Ratpoison\\\nComment=Minimalistic Window Manager\\\nExec=ratpoison\" > /usr/share/xsessions/ratpoison.desktop\""
		break;;

		#Xmonad
		[Xx]*) 	PACKAGES="$PACKAGES xmonad-contrib"; break;;
		#None
		[Nn]* ) break;; #Okay :_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:_\|/_:
		* ) echo "Please choose one!";;
	esac
done

#Xorg
case $SYSTEM in
	[Nn]* );;
	* ) echo -e "\n\033[31m*\033[0m Make sure your have the \"VIDEO_CARDS\" \"INPUT_DEVICES\" set correctly in make.conf\n";
		gentoo_commander post_message "\033[31mMake sure your have the VIDEO_CARDS INPUT_DEVICES set correctly in make.conf\033[0m"
	PACKAGES="$PACKAGES $DESKTOP_PACKAGES xorg-drivers";;
esac

#Add STANDARD_PACKAGES
PACKAGES="$PACKAGES $STANDARD_PACKAGES"

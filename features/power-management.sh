#!/bin/bash
#Power Management
#ACPI, screen-saver
#Does have cpu temp in the kernel help power management??
#http://www.gentoo.org/doc/en/power-management-guide.xml

PACKAGES="$PACKAGES sys-power/acpid hibernate-script"


read -p "Installing on a laptop? (No)" laptop;

	case $laptop in
		[yY]*) PACKAGES="$PACKAGES sys-power/acpitool laptop-mode-tools";;
	esac

gentoo_commander use_flags "acpi apm lm_sensors pmu"
gentoo_commander post_install "rc-update add acpid default"
gentoo_commander post_message "Power Management: Use \"hibernate-ram\" to put your computer to sleep"


#gentoo_commander post_install "rc-update add hdparm battery"
# echo "none  /tmp  tmpfs  size=32m  0 0" >> /etc/fstab

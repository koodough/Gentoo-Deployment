#!/bin/bash
#Pulseaudio

PACKAGES="$PACKAGES pulseaudio media-plugins/gst-plugins-pulse libflashsupport media-plugins/alsa-plugins"

gentoo_commander use_flags "pulseaudio"
gentoo_commander post_install "gpasswd -a $USERNAME pulse"
gentoo_commander post_install "gpasswd -a root pulse"
gentoo_commander post_install "gpasswd -a $USERNAME pulse-access"
gentoo_commander post_install "gpasswd -a root pulse-access"


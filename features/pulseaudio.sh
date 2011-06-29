#!/bin/bash
#Pulseaudio

PACKAGES="$PACKAGES pulseaudio media-plugins/gst-plugins-pulse libflashsupport media-plugins/alsa-plugins"

gentoo_commander use_flags "pulseaudio"

gpasswd -a $USERNAME pulse
gpasswd -a root pulse
gpasswd -a $USERNAME pulse-access
gpasswd -a root pulse-access


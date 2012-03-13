#!/bin/bash
# Bash Complete
# Bash complete for ssh sh screen mount nmap util-linux man make bash-builtins gentoo iptables lvm tar tcpdump service base findutils;

PACKAGES="$PACKAGES bash-completion";
gentoo_commander use_flags "bash-completion";
gentoo_commander post_install "echo \"#Adding by the Gentoo Install script\" >> /etc/bash/bashrc";
gentoo_commander post_install "echo \"[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh\" >> /etc/bash/bashrc";
gentoo_commander post_install "source /etc/profile"
gentoo_commander post_install "eselect bashcomp enable ssh sh screen mount nmap util-linux man make bash-builtins gentoo iptables lvm tar tcpdump service base findutils; echo \"Added basic bash-completion\""
gentoo_commander post_message "Bash Completion: Use eselect bashcomp list to find what you want to enable"

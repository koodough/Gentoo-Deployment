#!/bin/bash

# portage_tmpfs.sh
# Add tmpfs to your /etc/fstab to be use for portage so the harddrive isn't touch when compiling
# http://en.gentoo-wiki.com/wiki/Portage_TMPDIR_on_tmpfs


gentoo_commander pre_install "echo \"tmpfs /var/tmp/portage tmpfs size=500M 0 0\" >> /etc/fstab"
gentoo_commander post_message "To use tmpfs for /var/tmp/portage type mount -a"
gentoo_commander post_message "Make sure your have Virtual memory file system support (former shm fs) enabled in your kernel"  

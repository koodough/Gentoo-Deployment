#!/bin/bash

# prelink.sh
# Prelink helps binaries to start faster
# http://www.gentoo.org/doc/en/prelink-howto.xml


PACKAGES=prelink
gentoo_commander post_install "prelink -amR"
gentoo_commander post_message "Run prelink -amR if portage updates libraries"

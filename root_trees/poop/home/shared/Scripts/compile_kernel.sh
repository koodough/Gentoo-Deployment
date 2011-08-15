#!/bin/bash
cd /usr/src/linux/
time make && make modules_install && cp /usr/src/linux/arch/x86/boot/bzImage /boot/kernel-`date +%m-%d-%Y` && grub-mkconfig -o /boot/grub/grub.cfg

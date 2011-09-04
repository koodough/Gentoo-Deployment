!/bin/bash
cd /usr/src/linux/

#How many threads
if [[ -n $1 ]] ; then
J="-j$1"
fi

time make $J && make modules_install && cp /usr/src/linux/arch/x86/boot/bzImage /boot/kernel-`date +%m-%d-%Y` && grub-mkconfig -o /boot/grub/grub.cfg

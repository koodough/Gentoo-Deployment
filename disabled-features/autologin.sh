#!/bin/bash
#Autologin

echo -e "
#include <unistd.h>\n
\n
int main() {\n
   execlp( "login", "login", "-f", "$USERNAME", NULL);\n
}\n" > ./autologin.c;

gcc -o autologin autologin.c;

mv autologin /usr/local/sbin/

/* 
https://wiki.archlinux.org/index.php/Automatic_login_to_virtual_console
 
 In /etc/inittab

 c1:2345:respawn:/sbin/mingetty --autologin USERNAME tty1 linux
 c2:2345:respawn:/sbin/agetty -8 38400 tty2 linux
 c3:2345:respawn:/sbin/agetty -8 38400 tty3 linux
 c4:2345:respawn:/sbin/agetty -8 38400 tty4 linux
 c5:2345:respawn:/sbin/agetty -8 38400 tty5 linux
 c6:2345:respawn:/sbin/agetty -8 38400 tty6 linux
 */

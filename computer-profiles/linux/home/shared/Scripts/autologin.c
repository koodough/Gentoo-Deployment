#include <unistd.h>

int main() {
   execlp( "login", "login", "-f", "blue", NULL);
}

/* 
https://wiki.archlinux.org/index.php/Automatic_login_to_virtual_console
 
 In /etc/inittab
 c1:2345:respawn:/sbin/mingetty --autologin USERNAME tty1 linux
 c2:2345:respawn:/sbin/agetty -8 38400 tty2 linux
 c3:2345:respawn:/sbin/agetty -8 38400 tty3 linux
 c4:2345:respawn:/sbin/agetty -8 38400 tty4 linux
 c5:2345:respawn:/sbin/agetty -8 38400 tty5 linux
 c6:2345:respawn:/sbin/agetty -8 38400 tty6 linux
 
 The program must be compiled and copied to an appropriate location
 gcc -o autologin autologin.c
 cp autologin /usr/local/sbin/
*/

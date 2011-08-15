#!/bin/bash
CHOST=`cat /etc/make.conf | grep CHOST= | gawk -F\" '{print $2}'`
#CHOST="i686-pc-linux-gnu"
#CHOST="powerpc-unknown-linux-gnu"

cd /usr/lib/distcc/bin
rm c++ g++ gcc cc

echo -e '#!/bin/bash\nexec /usr/lib/distcc/bin/$CHOST-g${0:$[-2]} "$@"' > $CHOST-wrapper

chmod a+x $CHOST-wrapper

ln -s $CHOST-wrapper cc
ln -s $CHOST-wrapper gcc
ln -s $CHOST-wrapper g++
ln -s $CHOST-wrapper c++

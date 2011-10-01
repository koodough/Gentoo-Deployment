#!/bin/bash

CHOST="powerpc-unknown-linux-gnu"

cd /usr/lib/distcc/bin
rm c++ g++ gcc cc

cat '#!/bin/bash
exec /usr/lib/distcc/bin/powerpc-unknown-linux-gnu-g${0:$[-2]} "$@"' > /usr/lib/distcc/bin/powerpc-unknown-linux-gnu-wrapper

chmod a+x $CHOST-wrapper

ln -s $CHOST-wrapper cc
ln -s $CHOST-wrapper gcc
ln -s $CHOST-wrapper g++
ln -s $CHOST-wrapper c++

#!/bin/bash
#ccache
#CCache is a fast compiler cache. When you compile a program, it will cache intermediate results so that, whenever you recompile the same program, the compilation time is greatly reduced. The first time you run ccache, it will be much slower than a normal compilation. Subsequent recompiles should be faster. ccache is only helpful if you will be recompiling the same application many times; thus it's mostly only useful for software developers.
#Great when emerge fails and you have to recompile


gentoo_commander pre_install	"USE=\"-*\" emerge ccache"
gentoo_commander make_config	"CCACHE_SIZE=\"2G\""


#Could add PATH="/usr/lib/ccache/bin:/opt/bin:${PATH}" for non portage compiling

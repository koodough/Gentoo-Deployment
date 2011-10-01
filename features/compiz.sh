#!/bin/bash
#Compiz

#It's not complete without compiz.

PACKAGES="$PACKAGES x11-apps/fusion-icon x11-libs/compizconfig-backend-gconf x11-wm/emerald"
gentoo_commander pre_install "echo -e \"\n\n
#Compiz
dev-libs/protobuf\n                                                         
dev-util/intltool\n                                                           
dev-python/compizconfig-python\n                                               
x11-apps/ccsm\n                                                                
x11-libs/libcompizconfig\n                                                     
x11-libs/compizconfig-backend-gconf\n                                          
x11-libs/compizconfig-backend-kconfig4\n                                       
x11-libs/compiz-bcop\n                                                         
x11-plugins/compiz-plugins-main\n                                              
x11-plugins/compiz-plugins-extra\n                                            
x11-plugins/compiz-plugins-unsupported\n                                       
x11-themes/emerald-themes\n                                                    
x11-wm/compiz\n                                                                
x11-wm/compiz-fusion\n                                                         
x11-wm/emerald\n                                                               
x11-apps/fusion-icon\n                                                         
x11-wm/compiz-fusion\n
\" >> /etc/portage/package.keywords"


# Gentoo Deployment Version 4.1
by Koodough

## Objective
Install Gentoo on any computer with all the questions ask before the installation starts. 


## TODO
Create ./features/kernel.sh to install a working kernel
Better Debugging the progress of the Gentoo installation
Ability to isolate features to either test or execute
"install.sh" shouldn't copy the git repo to a target machine (not necessary to copy all those files)

## Introduction

Gentoo Deployment was only made to ease the installation of Gentoo by following through the official guides on gentoo.org. Although the script doesn't follow the guides line by line, it does a good job at least downloading the Stage3 and Portage tarball.

## Usage

Gentoo Deployment, runs best in a Gentoo environment, so either SystemrescueCD (testing OS) or a Gentoo Live CD will work fine on the target computer.

1. Target machine to install gentoo: git clone https://github.com/koodough/Gentoo-Deployment.git

or

1. Download Gentoo Deployment on any machine and then run 
./install.sh
This script will simply just copy the files to the target machine via ssh
Result: Gentoo Deployment folder should now by on your root folder on the target machine running some Gentoo environment operating system.

2. cd "/Gentoo Deployment"
3. Add or remove any features in the "features" folder. NOTE: Features can be very unstable, as many are still in the works
3. ./gentoo_deployment.sh
4. Follow through the steps from the ./gentoo_deployment.sh prompt 

### HELP!!!!
If your new to Gentoo, DON'T use this script. Rather follow the official documentation gentoo.org, trust me.

If your encountering a bug, please email me at github@koodough.com or through the github website, user name is koodough.

If you have no idea what this script does but understand the principles of installing Gentoo, then probably this script isn't ready for prime time, yet.



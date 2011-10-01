#!/bin/bash

directory_name="$( cd "$( dirname "$0" )" && pwd )"

function w
{
	echo "Appending $1 to $2"
	echo -e "$1" >> "$2"
}

w "set completion-ignore-case on" /etc/inputrc
w "export PATH='$directory_name:${PATH}'" /etc/bash/bashrc
w "alias screen='screen -xRRA'" /etc/bash/bashrc
w "screen -xRRA" /root/.profile

#!/bin/bash

#Basic raspberry pi setup

configdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f $configdir/raspi-setup-functions.sh ];
then
	echo -e "\e[91mraspi-setup-user not found in $configdir/raspi-setup-functions, exiting script"
	tput sgr0
	exit 2
fi

source "$configdir/raspi-setup-functions.sh"

echo ""
echo ""
echo -e "\e[95mConfig file format check"; tput sgr0

echo -e "\e[94mChecking needed config files..."; tput sgr0

ExitIfFileIsMissing "$configdir/config/maclist.txt"
ExitIfFileIsMissing "$configdir/config/gateway.txt"
ExitIfFileIsMissing "$configdir/config/hostlist.txt"
ExitIfFileIsMissing "$configdir/config/dnsserver.txt"
ExitIfFileIsMissing "$configdir/config/workgroup.txt"
ExitIfFileIsMissing "$configdir/config/subnet.txt"

echo -e "\e[94mSanitizing config files..."; tput sgr0
#Windows file format incompatible with some operations, 
#they should be converted to a linux compatible format

SanitizeWindowsFileFormat "$configdir/config/maclist.txt"
SanitizeWindowsFileFormat "$configdir/config/gateway.txt"
SanitizeWindowsFileFormat "$configdir/config/hostlist.txt"
SanitizeWindowsFileFormat "$configdir/config/dnsserver.txt"
SanitizeWindowsFileFormat "$configdir/config/workgroup.txt"
SanitizeWindowsFileFormat "$configdir/config/subnet.txt"


echo -e "\e[92mCompleted config file sanity check"; tput sgr0

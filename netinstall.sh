#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`

cd /tmp
opkg install git git-http

git clone https://github.com/Anonym-tsk/tpws-keenetic.git --depth 1
chmod +x ./tpws-keenetic/*.sh

./tpws-keenetic/install.sh
rm -rf tpws-keenetic

cd $HOME_FOLDER

exit 0

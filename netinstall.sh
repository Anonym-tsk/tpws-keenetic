#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`
BASE_URL="https://github.com/Anonym-tsk/tpws-keenetic/raw/master"

cd /tmp
mkdir -p tpws-keenetic/etc/tpws
mkdir -p tpws-keenetic/etc/init.d
mkdir -p tpws-keenetic/etc/ndm/netfilter.d
mkdir -p tpws-keenetic/common

curl -L "$BASE_URL/install.sh" -o "tpws-keenetic/install.sh"
curl -L "$BASE_URL/common/install_func.sh" -o "tpws-keenetic/common/install_func.sh"
curl -L "$BASE_URL/etc/tpws/tpws.conf" -o "tpws-keenetic/etc/tpws/tpws.conf"
curl -L "$BASE_URL/etc/tpws/user.list" -o "tpws-keenetic/etc/tpws/user.list"
curl -L "$BASE_URL/etc/tpws/auto.list" -o "tpws-keenetic/etc/tpws/auto.list"
curl -L "$BASE_URL/etc/init.d/S51tpws" -o "tpws-keenetic/etc/init.d/S51tpws"
curl -L "$BASE_URL/etc/ndm/netfilter.d/100-tpws.sh" -o "tpws-keenetic/etc/ndm/netfilter.d/100-tpws.sh"

chmod +x ./tpws-keenetic/*.sh
./tpws-keenetic/install.sh

rm -rf tpws-keenetic
cd $HOME_FOLDER

exit 0

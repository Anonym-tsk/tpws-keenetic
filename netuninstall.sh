#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`
BASE_URL="https://github.com/Anonym-tsk/tpws-keenetic/raw/master"

cd /tmp
mkdir -p tpws-keenetic/common

curl -SL# "$BASE_URL/uninstall.sh" -o "tpws-keenetic/uninstall.sh"
curl -SL# "$BASE_URL/common/install_func.sh" -o "tpws-keenetic/common/install_func.sh"

chmod +x ./tpws-keenetic/*.sh
./tpws-keenetic/uninstall.sh

rm -rf tpws-keenetic
cd $HOME_FOLDER

exit 0

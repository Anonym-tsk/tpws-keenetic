#!/bin/sh

. /opt/etc/tpws/tpws.conf

if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$type" == "ip6tables" ] && exit
[ "$table" != "nat" ] && exit

/opt/etc/init.d/S51tpws firewall

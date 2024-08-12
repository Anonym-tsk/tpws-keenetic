#!/bin/sh

. /opt/etc/tpws/tpws.conf

if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$table" != "nat" ] && exit

# $type is `iptables` or `ip6tables`
/opt/etc/init.d/S51tpws firewall-"$type"

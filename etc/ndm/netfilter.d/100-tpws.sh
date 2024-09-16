#!/bin/sh

PIDFILE="/opt/var/run/tpws.pid"
if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$table" != "nat" ] && exit

. /opt/etc/tpws/tpws.conf

# $type is `iptables` or `ip6tables`
/opt/etc/init.d/S51tpws firewall_"$type"

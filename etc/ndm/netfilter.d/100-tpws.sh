#!/bin/sh

. /opt/etc/tpws/tpws.conf

if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$type" == "ip6tables" ] && exit
[ "$table" != "nat" ] && exit

if [ -z "$(iptables-save 2>/dev/null | grep "to-ports $BIND_PORT$")" ]; then
  for IFACE in $LOCAL_INTERFACE; do
    iptables -t nat -A PREROUTING -i $IFACE -p tcp --dport 80 -j REDIRECT --to-port $BIND_PORT
    iptables -t nat -A PREROUTING -i $IFACE -p tcp --dport 443 -j REDIRECT --to-port $BIND_PORT
    iptables -t nat -A PREROUTING -i $IFACE -p udp --dport 443 -j REDIRECT --to-port $BIND_PORT
  done
fi

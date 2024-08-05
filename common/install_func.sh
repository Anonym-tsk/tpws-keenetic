#!/bin/sh

CONFFILE=/opt/etc/tpws.conf
LISTFILE=/opt/etc/tpws.list
TPWS_BIN=/opt/usr/bin/tpws
INIT_SCRIPT=/opt/etc/init.d/S51tpws
NETFILTER_SCRIPT=/opt/etc/ndm/netfilter.d/100-tpws.sh

stop_func() {
  if [ -f "$INIT_SCRIPT" ]; then
    $INIT_SCRIPT stop
  fi
}

start_func(){
  if [ -f "$INIT_SCRIPT" ]; then
    $INIT_SCRIPT start
  fi
}

read_yes_or_abort_func() {
  read yn
  case $yn in
    [Yy]* )
      ;;
    * )
      echo "Installation aborted"
      exit;;
  esac
}

begin_func() {
  echo ""
  echo "Begin install? y/N"
  read_yes_or_abort_func
}

check_old_config_func() {
  if [ -f "$CONFFILE" ]; then
    echo "Old config file found: $CONFFILE. It will be overwritten. Continue? y/N"
    read_yes_or_abort_func
  fi
}

install_packages_func() {
  opkg update
  opkg upgrade busybox
  opkg install iptables curl
}

config_copy_files_func() {
  cp -f $HOME_FOLDER/etc/init.d/S51tpws $INIT_SCRIPT
  chmod +x $INIT_SCRIPT

  cp -f $HOME_FOLDER/etc/ndm/netfilter.d/100-tpws.sh $NETFILTER_SCRIPT
  chmod +x $NETFILTER_SCRIPT

  cp -f $HOME_FOLDER/etc/tpws.conf $CONFFILE
  cp -f $HOME_FOLDER/etc/tpws.list $LISTFILE
}

config_select_arch_func() {
  if [ -z "$ARCH" ]; then
    echo "Select the router architecture: mips, mipsel (default), aarch64"
    read ARCH
  fi

  ARCH="mipsel"
  TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/tpws"

  if [ "$ARCH" == "mips" ]; then
    TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/tpws"
  elif [ "$ARCH" == "aarch64" ]; then
    TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/tpws"
  fi

  echo "Selected architecture: $ARCH"
  curl -L "$TPWS_URL" -o "$TPWS_BIN"
  chmod +x $TPWS_BIN
}

config_local_interface_func() {
  if [ -z "$BIND_IFACE" ]; then
    echo "Enter the local interface name from the list above, e.g. br0 (default) or nwg0"
    echo "You can specify multiple interfaces separated by space, e.g. br0 nwg0"
    read BIND_IFACE
  fi
  if [ -z "$BIND_IFACE" ]; then
    BIND_IFACE="br0"
  fi
  echo "Selected interface: $BIND_IFACE"

  sed -i 's/LOCAL_INTERFACE="br0"/LOCAL_INTERFACE="'$BIND_IFACE'"/' $CONFFILE
}

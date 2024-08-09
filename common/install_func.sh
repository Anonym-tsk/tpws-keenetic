#!/bin/sh

CONFDIR=/opt/etc/tpws
CONFFILE=$CONFDIR/tpws.conf
LISTFILE=$CONFDIR/user.list
LISTAUTOFILE=$CONFDIR/auto.list
LISTEXCLUDEFILE=$CONFDIR/exclude.list
LISTLOG=/opt/var/log/tpws.log
TPWS_BIN=/opt/usr/bin/tpws
INIT_SCRIPT=/opt/etc/init.d/S51tpws
NETFILTER_SCRIPT=/opt/etc/ndm/netfilter.d/100-tpws.sh
HOME_FOLDER="$HOME"


FontColor_Red="\033[31m"
FontColor_Green="\033[32m"
FontColor_Yellow="\033[33m"
FontColor_Suffix="\033[0m"

log() {
    LEVEL="$1"
    MSG="$2"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    case "$LEVEL" in
        INFO)
            printf "[${TIMESTAMP}] [${FontColor_Green}${LEVEL}${FontColor_Suffix}] %s\n" "${MSG}"
            ;;
        WARN)
            printf "[${TIMESTAMP}] [${FontColor_Yellow}${LEVEL}${FontColor_Suffix}] %s\n" "${MSG}"
            ;;
        ERROR)
            printf "[${TIMESTAMP}] [${FontColor_Red}${LEVEL}${FontColor_Suffix}] %s\n" "${MSG}" >&2
            ;;
        *)
            printf "[${TIMESTAMP}] %s\n" "${MSG}"
            ;;
    esac
}

stop_func() {
    if [ -f "$INIT_SCRIPT" ]; then
        log INFO "Stopping the service using $INIT_SCRIPT"
        "$INIT_SCRIPT" stop
    else
        log WARN "Init script not found: $INIT_SCRIPT"
    fi
}

start_func() {
    if [ -f "$INIT_SCRIPT" ]; then
        log INFO "Starting the service using $INIT_SCRIPT"
        "$INIT_SCRIPT" start
    else
        log WARN "Init script not found: $INIT_SCRIPT"
    fi
}

show_interfaces_func() {
    log INFO "Displaying network interfaces"
    printf "\n----------------------"
    ip addr show | awk -F" |/" '{gsub(/^ +/,"")}/inet /{print $(NF), $2}'
}

read_yes_or_abort_func() {
    read -r yn
    case $yn in
        [Yy]* )
            ;;
        * )
            log ERROR "Installation aborted"
            exit 1
            ;;
    esac
}

begin_install_func() {
    log INFO "Beginning installation"
    printf "\nBegin install? y/N"
    read_yes_or_abort_func
}

begin_uninstall_func() {
    log INFO "Beginning uninstallation"
    printf "\nBegin uninstall? y/N"
    read_yes_or_abort_func
}

remove_all_files_func() {
    log INFO "Removing all files"
    rm -f "$CONFFILE"
    rm -f "$TPWS_BIN"
    rm -f "$INIT_SCRIPT"
    rm -f "$NETFILTER_SCRIPT"
}

remove_list_func() {
    log INFO "Removing hosts list"
    printf "\nRemove hosts list? y/N"
    read -r yn
    case $yn in
        [Yy]* )
            rm -f "$LISTFILE"
            rm -f "$LISTAUTOFILE"
            rm -f "$LISTEXCLUDEFILE"
            ;;
    esac
}

check_old_config_func() {
    if [ -f "$CONFFILE" ]; then
        log WARN "Old config file found: $CONFFILE. It will be overwritten."
        printf "\nOld config file found: $CONFFILE. It will be overwritten. Continue? y/N"
        read_yes_or_abort_func
    fi
}

install_packages_func() {
    log INFO "Updating and installing packages"
    opkg update
    opkg upgrade busybox
    opkg install iptables
}

config_copy_files_func() {
    log INFO "Copying configuration files"
    cp -f "$HOME_FOLDER/etc/init.d/S51tpws" "$INIT_SCRIPT"
    chmod +x "$INIT_SCRIPT"

    cp -f "$HOME_FOLDER/etc/ndm/netfilter.d/100-tpws.sh" "$NETFILTER_SCRIPT"
    chmod +x "$NETFILTER_SCRIPT"

    mkdir -p "$CONFDIR"
    cp -f "$HOME_FOLDER/etc/tpws/tpws.conf" "$CONFFILE"
}

config_copy_list_func() {
    if [ -f "$LISTFILE" ]; then
        log INFO "Old hosts list file found: $LISTFILE. Overwriting it."
        printf "\nOld hosts list file found: $LISTFILE. Overwrite? y/N"
        read -r yn
        case $yn in
            [Yy]* )
                cp -f "$HOME_FOLDER/etc/tpws/user.list" "$LISTFILE"
                cp -f "$HOME_FOLDER/etc/tpws/auto.list" "$LISTAUTOFILE"
                cp -f "$HOME_FOLDER/etc/tpws/exclude.list" "$LISTEXCLUDEFILE"
                ;;
        esac
    else
        cp -f "$HOME_FOLDER/etc/tpws/user.list" "$LISTFILE"
        cp -f "$HOME_FOLDER/etc/tpws/auto.list" "$LISTAUTOFILE"
        cp -f "$HOME_FOLDER/etc/tpws/exclude.list" "$LISTEXCLUDEFILE"
    fi
}

config_select_arch_func() {
    if [ -z "$ARCH" ]; then
        log INFO "Selecting router architecture"
        printf "\nSelect the router architecture: mipsel (default), mips, aarch64"
        echo "  mipsel  - KN-1010/1011, KN-1810, KN-1910/1912, KN-2310, KN-2311, KN-2610, KN-2910, KN-3810"
        echo "  mips    - KN-2410, KN-2510, KN-2010, KN-2012, KN-2110, KN-2112, KN-3610"
        echo "  aarch64 - KN-2710, KN-1811"
        read -r ARCH
    fi

    case "$ARCH" in
        mips)
            TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/tpws"
            ;;
        aarch64)
            TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/tpws"
            ;;
        *)
            ARCH="mipsel"
            TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/tpws"
            ;;
    esac

    log INFO "Selected architecture: $ARCH"
    curl -SL# "$TPWS_URL" -o "$TPWS_BIN"
    chmod +x "$TPWS_BIN"
}

config_select_mode_func() {
    if [ -z "$MODE" ]; then
        log INFO "Selecting working mode"
        printf "\nSelect working mode: auto (default), list, all"
        echo "  auto - automatically detects blocked resources and adds them to the list"
        echo "  list - applies rules only to domains in the list $LISTFILE"
        echo "  all  - applies rules to all traffic except domains from list $LISTEXCLUDEFILE"
        read -r MODE
    fi

    case "$MODE" in
        list)
            EXTRA_ARGS="--hostlist=$LISTFILE"
            ;;
        all)
            EXTRA_ARGS="--hostlist-exclude=$LISTEXCLUDEFILE"
            ;;
        *)
            MODE="auto"
            EXTRA_ARGS="--hostlist=$LISTFILE --hostlist-auto=$LISTAUTOFILE --hostlist-auto-debug=$LISTLOG --hostlist-exclude=$LISTEXCLUDEFILE"
            ;;
    esac
    log INFO "Selected mode: $MODE"

    sed -i "s#INPUT_EXTRA_ARGS#$EXTRA_ARGS#" "$CONFFILE"
}

config_local_interface_func() {
    if [ -z "$BIND_IFACE" ]; then
        log INFO "Selecting local interface"
        printf "\nEnter the local interface name from the list above, e.g. br0 (default) or nwg0"
        echo "You can specify multiple interfaces separated by space, e.g. br0 nwg0"
        read -r BIND_IFACE
    fi
    if [ -z "$BIND_IFACE" ]; then
        BIND_IFACE="br0"
    fi
    log INFO "Selected interface: $BIND_IFACE"

    sed -i "s#INPUT_LOCAL_INTERFACE#$BIND_IFACE#" "$CONFFILE"
}

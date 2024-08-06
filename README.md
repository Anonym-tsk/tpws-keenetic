# tpws-keenetic

### Automatic installation
```
opkg install curl
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/tpws-keenetic/raw/master/netinstall.sh)"
```

### Automatic uninstallation
```
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/tpws-keenetic/raw/master/netuninstall.sh)"
```

### Manual installation
```
opkg install git git-http curl
git clone https://github.com/Anonym-tsk/tpws-keenetic.git --depth 1
chmod +x ./tpws-keenetic/*.sh
./tpws-keenetic/install.sh
```

### Manual uninstallation
```
./tpws-keenetic/uninstall.sh
```


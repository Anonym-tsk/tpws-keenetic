# tpws-keenetic

Скрипты для установки `tpws` на маршрутизаторы с поддержкой `opkg`.

> **Вы пользуетесь этой инструкцией на свой страх и риск!**
> 
> Автор не несёт ответственности за порчу оборудования и программного обеспечения, проблемы с доступом и потенцией.
> Подразумевается, что вы понимаете, что вы делаете.

Предназначено для роутеров Keenetic с установленным на них entware, а так же для любой системы с opkg пакетами, у которых система расположена в каталоге /opt/.

Проверено на маршрутизаторах:

- Keenetic Giga (KN-1011)
- Keenetic Ultra (KN-1811)
- Keenetic Extra (KN-1710)
- Keenetic Hopper (KN-3810)
- Keenetic Hopper DSL (KN-3610)
- Keenetic Viva (KN-1910)
- ZyXEL Keenetic Giga II
- ZyXEL Keenetic Ultra II
- ZyXEL Keenetic Ultra
- SmartBOX Turbo+ с прошивкой Padavan
- Xiaomi Mi-router 3 с прошивкой Padavan
- Xiaomi Mi Router PRO R3P с прошивкой Keenetic OS
- Xiaomi Mi WiFi Router 3G

Списки проверенного оборудования собираем в [отдельной теме](https://github.com/Anonym-tsk/tpws-keenetic/discussions/6).

Поделиться опытом можно в разделе [Discussions](https://github.com/Anonym-tsk/tpws-keenetic/discussions).

Если вы не уверены, что вам нужен именно tpws, лучше сначала попробуйте [nfqws](https://github.com/Anonym-tsk/nfqws-keenetic).

### Что это?

`tpws` - утилита для модификации TCP пакетов на уровне потока, работает как TCP transparent proxy.

**`tpsw` не работает с UDP и не обрабатывает QUIC.**

Почитать подробнее можно на [странице авторов](https://github.com/bol-van/zapret) (ищите по ключевому слову `tpws`).

### Подготовка

- Рекомендуется отключить провайдерский DNS на маршрутизаторе и [настроить использование DoT/DoH](https://help.keenetic.com/hc/ru/articles/360007687159) (опционально).

- Установить entware на маршрутизатор по инструкции [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880) или [на USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160).

- Через web-интерфейс Keenetic установить пакет **Протокол IPv6** (сам IPv6 можно не включать и не использовать).

- Все дальнейшие команды выполняются не в cli роутера, а **в среде entware**.

### Автоматическая установка (рекомендуется)

```
opkg install curl
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/tpws-keenetic/raw/master/netinstall.sh)"
```

**Следуйте инструкции установщика:**

1. Выберите архитектуру маршрутизатора `mipsel`, `mips`, `aarch64` или `arm`
> Для моделей Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912), Hero 4G (KN-2310), Hero 4G+ (KN-2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810) используйте архитектуру `mipsel`
>
> Для моделей Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610) используйте архитектуру `mips`
>
> Для моделей Peak (KN-2710), Ultra (KN-1811) используйте архитектуру `aarch64`
>
> Для других устройств доступен вариант `arm`
2. Введите локальный сетевой интерфейс, обычно это `br0`
> Можно указать несколько интерфейсов через пробел (`br0 nwg0`), например, чтобы обрабатывать трафик от клиентов, подключенных через VPN или в гостевой сети
3. Выберите режим работы `auto`, `list` или `all`
> В режиме `list` будут обрабатываться только домены из файла `/opt/etc/tpws/user.list` (один домен на строку)
>
> В режиме `auto` кроме этого будут автоматически определяться недоступные домены и добавляться в список, по которому `tpws` обрабатывает трафик. Домен будет добавлен, если за 60 секунд будет 3 раза определено, что ресурс недоступен
>
> В режиме `all` будет обрабатываться весь трафик кроме доменов из списка `/opt/etc/tpws/exclude.list`
4. Укажите, нужна ли поддержка IPv6
> Если не уверены, лучше не отключайте и оставьте как есть

##### Обновление

Просто запустите установщик еще раз, следуйте инструкциям

```
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/tpws-keenetic/raw/master/netinstall.sh)"
```

##### Автоматическое удаление

```
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/tpws-keenetic/raw/master/netuninstall.sh)"
```

### Ручная установка (не рекомендуется, если entware установлен во внутреннюю память)

```
opkg install git git-http curl
git clone https://github.com/Anonym-tsk/tpws-keenetic.git --depth 1
chmod +x ./tpws-keenetic/*.sh
./tpws-keenetic/install.sh
```

##### Обновление

```
cd tpws-keenetic
git pull --depth=1
./install.sh
```

##### Удаление

```
./tpws-keenetic/uninstall.sh
```

### Полезное

1. Конфиг-файл `/opt/etc/tpws/tpws.conf`
2. Скрипт запуска/остановки `/opt/etc/init.d/S51tpws {start|stop|restart|reload|status|version}`
3. Вручную добавить домены в список можно в файле `/opt/etc/tpws/user.list` (один домен на строке, поддомены учитываются автоматически)
4. Автоматически добавленные домены `/opt/etc/tpws/auto.list`
5. Лог автоматически добавленных доменов `/opt/var/log/tpws.log`
6. Домены-исключения `/opt/etc/tpws/exclude.list` (один домен на строке, поддомены учитываются автоматически)
7. Проверить, что нужные правила добавлены в таблицу маршрутизации `iptables-save | grep "to-ports 999$"`
> Вы должны увидеть похожие строки (по 3 на каждый выбранный сетевой интерфейс)
> ```
> -A PREROUTING -i br0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 999
> -A PREROUTING -i br0 -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 999
> -A PREROUTING -i br0 -p udp -m udp --dport 443 -j REDIRECT --to-ports 999
> ```
8. Если ничего не работает...
> Если ваше устройство поддерживает аппаратное ускорение (flow offloading, hardware nat, hardware acceleration), то iptables могут не работать.
> При включенном offloading пакет не проходит по обычному пути netfilter.
> Необходимо или его отключить, или выборочно им управлять.
>
> На Keenetic можно попробовать выключить или наоборот включить [сетевой ускоритель](https://help.keenetic.com/hc/ru/articles/214470905)
>
> Возможно, стоит выключить службу классификации трафика IntelliQOS
>
> Теоретически, сервис должен работать с IPv6.
> Но можно попробовать отключить IPv6 на сетевом интерфейсе провайдера через веб-интерфейс маршрутизатора.
>
> Можно попробовать запретить весь UDP трафик на 443 порт для отключения QUIC
> ```
> iptables -I FORWARD -i br0 -p udp --dport 443 -j DROP
> ```

---

Нравится проект? [Поддержи автора](https://yoomoney.ru/to/410019180291197)! Купи ему немного :beers: или :coffee:!

# tpws-keenetic

Пакеты для установки `tpws` на маршрутизаторы с поддержкой `opkg`.

> Данный материал подготовлен в научно-технических целях.
> Использование предоставленных материалов в целях отличных от ознакомления может являться нарушением действующего законодательства.
> Автор не несет ответственности за неправомерное использование данного материала.

> **Вы пользуетесь этой инструкцией на свой страх и риск!**
> 
> Автор не несёт ответственности за порчу оборудования и программного обеспечения, проблемы с доступом и потенцией.
> Подразумевается, что вы понимаете, что вы делаете.

Изначально написано для роутеров Keenetic с установленным entware.
Однако, работоспособность также была проверена на прошивках Padavan и OpenWRT (читайте ниже).

Списки проверенного оборудования собираем в [отдельной теме](https://github.com/Anonym-tsk/tpws-keenetic/discussions/6).

Поделиться опытом можно в разделе [Discussions](https://github.com/Anonym-tsk/tpws-keenetic/discussions) или в [чате](https://t.me/nfqws).

Если вы не уверены, что вам нужен именно tpws, лучше сначала попробуйте [nfqws](https://github.com/Anonym-tsk/nfqws-keenetic).

### Что это?

`tpws` - утилита для модификации TCP пакетов на уровне потока, работает как TCP transparent proxy.

**`tpsw` не работает с UDP и не обрабатывает QUIC.**

Почитать подробнее можно на [странице авторов](https://github.com/bol-van/zapret) (ищите по ключевому слову `tpws`).

### Подготовка Keenetic

- Прочитайте инструкцию полностью, прежде, чем начать что-то делать!

- Рекомендуется игнорировать предложенные провайдером адреса DNS-серверов. Для этого в интерфейсе роутера отметьте пункты ["игнорировать DNS от провайдера"](https://help.keenetic.com/hc/ru/articles/360008609399) в настройках IPv4 и IPv6.
 
- Вместе с этим рекомендуется [настроить использование DoT/DoH](https://help.keenetic.com/hc/ru/articles/360007687159).

- Установить entware на маршрутизатор по инструкции [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880) или [на USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160).

- Через web-интерфейс Keenetic установить пакеты **Протокол IPv6** (**Network functions > IPv6**) и **Модули ядра подсистемы Netfilter** (**OPKG > Kernel modules for Netfilter** - не путать с "Netflow"). Обратите внимание, что второй компонент отобразится в списке пакетов только после того, как вы отметите к установке первый.

- В разделе "Интернет-фильтры" отключить все сторонние фильтры (NextDNS, SkyDNS, Яндекс DNS и другие).

- Все дальнейшие команды выполняются не в cli роутера, а **в среде entware**. Подключиться в неё можно несколькими способами:
  - Через telnet: в терминале выполнить `telnet 192.168.1.1`, а потом `exec sh`.
  - Или же подключиться напрямую через SSH (логин - `root`, пароль по умолчанию - `keenetic`, порт - 222 или 22). Для этого в терминале написать `ssh 192.168.1.1 -l root -p 222`.

> **Миграция с версии 1.x.x на 2.x.x:**
> 
> Для определения версии выполните команду `opkg info tpws-keenetic` - она работает только на версиях 2.x.x и возвращает информацию о пакете.
> Если ничего не вернула – у вас установлена старая версия.
>
> Никакой специальной миграции не требуется, просто переустановите новую версию по инструкции ниже.

---

### Установка на Keenetic и Entware

1. Установите необходимые зависимости
   ```
   opkg update
   opkg install ca-certificates wget-ssl
   opkg remove wget-nossl
   ```

2. Установите opkg-репозиторий в систему
   ```
   mkdir -p /opt/etc/opkg
   echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/all" > /opt/etc/opkg/tpws-keenetic.conf
   ```
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `aarch64`, `armv7`

   <details>
     <summary>Или можете выбрать репозиторий под конкретную архитектуру</summary>

     - `mips-3.4` <sub><sup>Keenetic Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610)</sup></sub>
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/mips" > /opt/etc/opkg/tpws-keenetic.conf
       ```

     - `mipsel-3.4` <sub><sup>Keenetic Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912), Hero 4G (KN-2310), Hero 4G+ (KN-2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810)</sup></sub>
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/mipsel" > /opt/etc/opkg/tpws-keenetic.conf
       ```

     - `aarch64-3.10` <sub><sup>Keenetic Peak (KN-2710), Ultra (KN-1811), Hopper SE (KN-3812), Keenetic Giga (KN-1012)</sup></sub>
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/aarch64" > /opt/etc/opkg/tpws-keenetic.conf
       ```

     - `armv7-3.2`
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/armv7" > /opt/etc/opkg/tpws-keenetic.conf
       ```
   </details>

3. Установите пакет
   ```
   opkg update
   opkg install tpws-keenetic
   ```

##### Обновление

```
opkg update
opkg upgrade tpws-keenetic
```

##### Удаление

```
opkg remove tpws-keenetic
```

##### Информация об установленной версии

```
opkg info tpws-keenetic
```

---

### Установка на OpenWRT

Пакет работает только с `iptables`.
Если в вашей системе используется `nftables`, придется удалить `nftables` и `firewall4`, и установить `firewall3` и `iptables`.

Проверить, что ваша система использует `nftables`:
```
ls -la /sbin/fw4
which nft
```

1. Установите необходимые зависимости
   ```
   opkg update
   opkg install ca-certificates wget-ssl
   opkg remove wget-nossl
   ```

2. Установите публичный ключ репозитория
   ```
   wget -O "/tmp/tpws-keenetic.pub" "https://anonym-tsk.github.io/tpws-keenetic/openwrt/tpws-keenetic.pub"
   opkg-key add /tmp/tpws-keenetic.pub
   ```

3. Установите opkg-репозиторий в систему
   ```
   echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/openwrt" > /etc/opkg/tpws-keenetic.conf
   ```
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `aarch64`, `armv7`.
   Для добавления поддержки новых устройств, [создайте Feature Request](https://github.com/Anonym-tsk/tpws-keenetic/issues/new?template=feature_request.md&title=%5BFeature+request%5D+)

4. Установите пакет
   ```
   opkg update
   opkg install tpws-keenetic
   ```

> NB: Все пути файлов, описанные в этой инструкции, начинающиеся с `/opt`, на OpenWRT будут начинаться с корня `/`.
> Например конфиг расположен в `/etc/tpws/tpws.conf`
> 
> Для запуска/остановки используйте команду `service tpws-keenetic {start|stop|restart|reload|status}`

---

### Настройки

Файл настроек расположен по пути `/opt/etc/tpws/tpws.conf`. Для редактирования можно воспользоваться встроенным редактором `vi` или установить `nano`.

```
# Интерфейс локальной сети. Обычно `br0`, на OpenWRT - `br-lan`
# Заполняется автоматически при установке
# Можно ввести несколько интерфейсов, например LOCAL_INTERFACE="br0 nwg0"
LOCAL_INTERFACE="br0"

# Стратегия обработки трафика
TPWS_ARGS="--bind-wait-ip=10 --disorder --tlsrec=sni --split-http-req=method --split-pos=2"

Режим работы (auto, list, all)
TPWS_EXTRA_ARGS="--hostlist=/opt/etc/tpws/user.list --hostlist-auto=/opt/etc/tpws/auto.list --hostlist-auto-debug=/opt/var/log/tpws.log --hostlist-exclude=/opt/etc/tpws/exclude.list"

# Обрабатывать ли IPv6 соединения
IPV6_ENABLED=1

# Обрабатывать ли HTTP
HTTP_ENABLED=0

# Логирование в Syslog (0 - silent, 1 - default, 2 - debug)
LOG_LEVEL=0
```

---

### Полезное

1. Конфиг-файл `/opt/etc/tpws/tpws.conf`
2. Скрипт запуска/остановки `/opt/etc/init.d/S51tpws {start|stop|restart|reload|status}`
3. Вручную добавить домены в список можно в файле `/opt/etc/tpws/user.list` (один домен на строке, поддомены учитываются автоматически)
4. Автоматически добавленные домены `/opt/etc/tpws/auto.list`
5. Лог автоматически добавленных доменов `/opt/var/log/tpws.log`
6. Домены-исключения `/opt/etc/tpws/exclude.list` (один домен на строке, поддомены учитываются автоматически)
7. Проверить, что нужные правила добавлены в таблицу маршрутизации `iptables-save | grep "to-ports 999$"`
> Вы должны увидеть похожие строки
> ```
> -A PREROUTING -i br0 -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 999
> ```

### Если ничего не работает...

1. Если ваше устройство поддерживает аппаратное ускорение (flow offloading, hardware nat, hardware acceleration), то iptables могут не работать.
   При включенном offloading пакет не проходит по обычному пути netfilter.
   Необходимо или его отключить, или выборочно им управлять.
2. На Keenetic можно попробовать выключить или наоборот включить [сетевой ускоритель](https://help.keenetic.com/hc/ru/articles/214470905)
3. Возможно, стоит выключить службу классификации трафика IntelliQOS.
4. Можно попробовать отключить IPv6 на сетевом интерфейсе провайдера через веб-интерфейс маршрутизатора.
5. Можно попробовать запретить весь UDP трафик на 443 порт для отключения QUIC:
   ```
   iptables -I FORWARD -i br0 -p udp --dport 443 -j DROP
   ```

---

Нравится проект? [Поддержи автора](https://yoomoney.ru/to/410019180291197)! Купи ему немного :beers: или :coffee:!

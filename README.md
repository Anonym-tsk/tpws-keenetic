# tpws-keenetic

[![GitHub Release](https://img.shields.io/github/release/Anonym-tsk/tpws-keenetic?style=flat&color=green)](https://github.com/Anonym-tsk/tpws-keenetic/releases)
[![GitHub Stars](https://img.shields.io/github/stars/Anonym-tsk/tpws-keenetic?style=flat)](https://github.com/Anonym-tsk/tpws-keenetic/stargazers)
[![License](https://img.shields.io/github/license/Anonym-tsk/tpws-keenetic.svg?style=flat&color=orange)](LICENSE)
[![CloudTips](https://img.shields.io/badge/donate-CloudTips-598bd7.svg?style=flat)](https://pay.cloudtips.ru/p/054d0666)
[![YooMoney](https://img.shields.io/badge/donate-YooMoney-8037fd.svg?style=flat)](https://yoomoney.ru/to/410019180291197)
[![Join Telegram group](https://img.shields.io/badge/Telegram_group-Join-blue.svg?style=social&logo=telegram)](https://t.me/nfqws)

Пакеты для установки `tpws` на маршрутизаторы.

> [!IMPORTANT]
> Данный материал подготовлен в научно-технических целях.
> Использование предоставленных материалов в целях отличных от ознакомления может являться нарушением действующего законодательства.
> Автор не несет ответственности за неправомерное использование данного материала.

> [!WARNING]
> **Вы пользуетесь этой инструкцией на свой страх и риск!**
> 
> Автор не несёт ответственности за порчу оборудования и программного обеспечения, проблемы с доступом и потенцией.
> Подразумевается, что вы понимаете, что вы делаете.

Изначально написано для роутеров Keenetic/Netcraze с установленным entware.
Однако, работоспособность также была проверена на прошивках Padavan и OpenWRT (читайте ниже).

Списки проверенного оборудования собираем в [отдельной теме](https://github.com/Anonym-tsk/tpws-keenetic/discussions/6).

Поделиться опытом можно в разделе [Discussions](https://github.com/Anonym-tsk/tpws-keenetic/discussions) или в [чате](https://t.me/nfqws).

Если вы не уверены, что вам нужен именно tpws, лучше сначала попробуйте [nfqws](https://github.com/Anonym-tsk/nfqws-keenetic).

### Что это?

`tpws` - утилита для модификации TCP пакетов на уровне потока, работает как TCP transparent proxy.

**`tpws` не работает с UDP и не обрабатывает QUIC.**

Почитать подробнее можно на [странице авторов](https://github.com/bol-van/zapret) (ищите по ключевому слову `tpws`).

### Подготовка Keenetic/Netcraze

- Прочитайте инструкцию полностью, прежде, чем начать что-то делать!

- Рекомендуется игнорировать предложенные провайдером адреса DNS-серверов. Для этого в интерфейсе роутера отметьте пункты ["игнорировать DNS от провайдера"](https://help.keenetic.com/hc/ru/articles/360008609399) в настройках IPv4 и IPv6.
 
- Вместе с этим рекомендуется [настроить использование DoT/DoH](https://help.keenetic.com/hc/ru/articles/360007687159).

- Установить entware на маршрутизатор по инструкции [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880) или [на USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160).

- Через web-интерфейс Keenetic/Netcraze установить пакеты **Протокол IPv6** (**Network functions > IPv6**) и **Модули ядра подсистемы Netfilter** (**OPKG > Kernel modules for Netfilter** - не путать с "Netflow"). Обратите внимание, что второй компонент отобразится в списке пакетов только после того, как вы отметите к установке первый.

- В разделе "Интернет-фильтры" отключить все сторонние фильтры (NextDNS, SkyDNS, Яндекс DNS и другие).

- Все дальнейшие команды выполняются не в cli роутера, а **в среде entware**. Подключиться в неё можно несколькими способами:
  - Через telnet: в терминале выполнить `telnet 192.168.1.1`, а потом `exec sh`.
  - Или же подключиться напрямую через SSH (логин - `root`, пароль по умолчанию - `keenetic`, порт - 222 или 22). Для этого в терминале написать `ssh 192.168.1.1 -l root -p 222`.

---

### Установка на Keenetic/Netcraze и другие системы с Entware

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
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `aarch64`, `armv7`, `x86`, `x86_64`.

   <details>
     <summary>Или можете выбрать репозиторий под конкретную архитектуру</summary>

     - `mips-3.4` <sub><sup>Keenetic Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610); Zyxel Keenetic DSL, LTE, VOX</sup></sub>
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/mips" > /opt/etc/opkg/tpws-keenetic.conf
       ```

     - `mipsel-3.4` <sub><sup>Keenetic 4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912/1913), Hero 4G (KN-2310/2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810); Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II</sup></sub>
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/mipsel" > /opt/etc/opkg/tpws-keenetic.conf
       ```

     - `aarch64-3.10` <sub><sup>Keenetic Peak (KN-2710), Ultra (KN-1811), Hopper (KN-3811), Hopper SE (KN-3812), Giga (KN-1012)</sup></sub>
       ```
       mkdir -p /opt/etc/opkg
       echo "src/gz tpws-keenetic https://anonym-tsk.github.io/tpws-keenetic/aarch64" > /opt/etc/opkg/tpws-keenetic.conf
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

### Установка на OpenWRT (до версии 24.10 включительно, пакетный менеджер `opkg`)

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
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `aarch64`, `armv7`, `x86`, `x86_64`.
   Для добавления поддержки новых устройств, [создайте Feature Request](https://github.com/Anonym-tsk/tpws-keenetic/issues/new?template=feature_request.md&title=%5BFeature+request%5D+)

4. Установите пакет
   ```
   opkg update
   opkg install tpws-keenetic
   ```

> [!NOTE]
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
LOCAL_INTERFACE="..."

# Стратегия обработки трафика
TPWS_ARGS="..."

Режим работы (auto, list, all)
TPWS_EXTRA_ARGS="..."

# Обрабатывать ли IPv6 соединения
IPV6_ENABLED=0|1

# Обрабатывать ли HTTP
HTTP_ENABLED=0|1

# Логирование в Syslog (0 - silent, 1 - default, 2 - debug)
LOG_LEVEL=0|1|2
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
2. На Keenetic/Netcraze можно попробовать выключить или наоборот включить [сетевой ускоритель](https://help.keenetic.com/hc/ru/articles/214470905)
3. Возможно, стоит выключить службу классификации трафика IntelliQOS.
4. Можно попробовать отключить IPv6 на сетевом интерфейсе провайдера через веб-интерфейс маршрутизатора.
5. Можно попробовать запретить весь UDP трафик на 443 порт для отключения QUIC:
   ```
   iptables -I FORWARD -i br0 -p udp --dport 443 -j DROP
   ```

---

Нравится проект? Поддержи автора [здесь](https://yoomoney.ru/to/410019180291197) или [тут](https://pay.cloudtips.ru/p/054d0666). Купи ему немного :beers: или :coffee:!

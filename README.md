# Проектная работа для курса OTUS Administrator Linux. Professional

## Цель

Цель данного выпускного проекта курса OTUS Administrator Linux. Professional состоит в разработке надежной инфраструктуры кластера веб-серверов для сайта на платформе WordPress. Проект предполагает автоматический запуск четырех серверов, каждый из которых обладает специфической функциональностью для обеспечения непрерывной работы системы.

##  Схема проекта
![alt text](shema_act.png?raw=true "Screenshot1")

## Описание инфраструктуры проекта


#### Сервер Testpr1:
* Граничный сервер с двумя сетевыми интерфейсами: внешним (```192.168.56.10```) и внутренним, нацеленным на DMZ (```10.10.62.10```). Внешний интерфейс обеспечивает доступ из внешней сети, а внутренний служит для связи с DMZ.
* Настроен IPTables для обеспечения безопасности сервера и контроля трафика, разрешены входящие порты:
    - 22 для SSH, разрешает удаленное управление сервером.
    - 443 для HTTPS, разрешает входящий трафик к веб-серверу (Nginx).
    - 9100 для Node Exporter, разрешает мониторинг сервера с помощью инструментов Prometheus.
* Nginx развернут в качестве обратного прокси-сервера, который перенаправляет запросы к серверам Apache - Testpr2 и Testpr3. Nginx обрабатывает входящие запросы по протоколу HTTPS и перенаправляет их на соответствующие серверы Apache через HTTP. Конфигурация Nginx находится в файле nginx.conf. Включены оптимизации, такие как gzip сжатие и кэширование статического контента для улучшения производительности.
* Используются самоподписанные сертификаты SSL/TLS, которые генерируются автоматически с помощью скрипта ```cert-generator.sh```. Пути к сертификатам указаны в конфигурационном файле ```nginx.conf```.

#### Сервера Testpr2 и Testpr3:
* Установлены серверы Apache с поддержкой PHP и WordPress. Конфигурация серверов Apache находится в файле ```/etc/httpd/conf/httpd.conf```.
* MySQL развернута на серверах Testpr2 и Testpr3 в режиме репликации master-backup. Основной сервер (master) обрабатывает все запросы на изменение данных, а резервный сервер (backup) получает копии данных с основного сервера. Конфигурация MySQL находится в файле my.cnf, созданном на основе шаблона ```my_cnf.j2_mysql```. Репликация master-backup предпочтительна для данного проекта, так как она обеспечивает упрощенное управление и меньшие риски конфликтов данных по сравнению с master-master.
* Репликация MySQL осуществляется с использованием binlog и GTID. В случае сбоя основного сервера, резервный сервер автоматически переключается на роль основного.
* Для автоматического переключения между серверами используется Keepalived с общим виртуальным IP-адресом для MySQL. Настроены сетевые интерфейсы с использованием виртуального IP-адреса для обеспечения доступности. Используется интерфейс с настроенными статическими IP-адресами для каждого сервера. Виртуальный IP-адрес (VIP) настроен на eth1 интерфейсе, который использует Keepalived для автоматического переключения между серверами в случае сбоя одного из них. Keepalived работает с протоколом VRRP (Virtual Router Redundancy Protocol), который обеспечивает автоматический выбор Master и Backup серверов для обработки трафика.
* Синхронизация данных между серверами осуществляется с использованием rsync с интервалом в одну минуту. Скрипт синхронизации использует rsync для копирования файлов между серверами и записывает результаты в лог-файл.
* Сервера Testpr2 и Testpr3 выполняют регулярное резервное копирование баз данных и данных WordPress на сервер Testpr4. Резервное копирование настраивается с помощью скрипта, добавленного в cron. Скрипт использует инструмент mysqldump для резервного копирования баз данных и rsync для копирования данных WordPress на сервер Testpr4.
* Резервные копии сохраняются в директориях ```/var/backup/testpr*``` с указанием даты создания, а информация о выполнении процесса резервного копирования записывается в файл ```/var/log/backup.txt``` на серверах Testpr2 и Testpr3.


#### Сервер Testpr4:
* Отвечает за мониторинг и визуализацию данных с использованием систем Prometheus и Grafana. Дополнительно загружено несколько наиболее информативных дашбордов.
* На всех серверах установлены соответствующие node_exporter, а на серверах Testpr2 и Testpr3 - mysql_exporter. Эти экспортеры собирают метрики с серверов и отправляют их в Prometheus. В Grafana настроены дашборды для визуализации данных с экспортеров.
* Testpr4 также выполняет функции сервера логирования (Rsyslog) для серверов Testpr2 и Testpr3. Централизованное хранение и анализ логов всех серверов облегчает процесс мониторинга и выявления проблем в инфраструктуре. Конфигурация Rsyslog находится в файле /etc/rsyslog.conf, а логи сохраняются в соответствующих директориях ```/var/log/rsyslog/test-pr*```.
* На сервере Testpr4 настроена ротация лог-файлов, что предотвращает их чрезмерный рост и облегчает анализ данных. Архивированные лог-файлы сжимаются и хранятся в соответствующих каталогах с регулярным удалением устаревших данных.
* Используется для хранения резервных копий. Резервные копии располагаются в папках ```/var/backup/testpr*```. Для копирования бэкапов предусмотрен отдельный скрипт ```copy_backup.sh```
Для автоматического развертывания и настройки всех серверов используются Vagrant и Ansible. Vagrantfile содержит описание виртуальных машин, а ```ansible-main-playbook``` представляет собой главный плейбук Ansible, который включает различные роли для настройки серверов. Это обеспечивает быстрое и удобное развертывание инфраструктуры проекта с минимальными затратами времени и усилий.

Для обеспечения безопасности системы на всех серверах используется SELinux. 

## Заключение
В итоге, данный проект представляет собой попытку создать надежную и отказоустойчивую инфраструктуру веб-серверов на базе WordPress, состоящую из четырех серверов, где каждый сервер выполняет специфическую роль. Комплексное взаимодействие серверов обеспечивает приемлемую непрерывность работы системы, балансировку нагрузки, централизованный мониторинг и логирование, а также резервное копирование данных.


#### Дополнения

Для корректного запуска необходимо в файл hosts на хостовой машине добавить следующие строки:
```
192.168.56.10   wp.lab.local
192.168.56.10   grafana.lab.local
192.168.56.10   prometheus.lab.local
```

Доступны следующие ресурсы:

* https://wp.lab.local/ - тестовый сайт;
* https://grafana.lab.local/login - панель управления мониторингом и аналитикой;
* https://prometheus.lab.local/targets - система мониторинга. 

Данные аутентификации для панели администрирования WordPress: 
- логин - wpadmin, 
- пароль - f7#swo56d@fLR3. 
- URL: https://wp.lab.local/wordpress/wp-admin/

Данные аутентификации для панели визуализации метрик и мониторинга Grafana: 
- логин - admin, 
- пароль - HTdfg78345Kl+k3 
- URL: https://grafana.lab.local/login

##### Перед запуском не забыть добавить архив с актуальными файлами Wordpress в /roles/wordpress/files/


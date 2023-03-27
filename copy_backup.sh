#!/bin/bash

DIR="26032023-01-40"
SOURCE_DIR="/var/backup/testpr2/$DIR"

# Копирование папки с гостевой машины testpr4
scp -i /home/egor/OTUS/new/123/.vagrant/machines/testpr4/virtualbox/private_key -P 2202 -r vagrant@127.0.0.1:"$SOURCE_DIR" ./"$DIR"

# Изменение прав доступа к скопированным файлам
chmod -R 777 $DIR

# Перемещение файлов backup-testpr2-wp_data.tar.gz и backup-testpr2-sql.sql.gz
mv "$DIR/backup-testpr2-wp_data.tar.gz" /home/egor/OTUS/new/123/roles/wordpress/files/wordpress.tar.gz
mv "$DIR/backup-testpr2-sql.sql.gz" /home/egor/OTUS/new/123/roles/mysql/files/wordpress/wordpress.sql.gz
#!/usr/bin/sh

DB=wordpress;
USER='admin'
PASS=rRxTh=YdFrwk3
DIR="/root/files/wordpress"
DUMP_FILE="wordpress.sql.gz"

# Распаковка дампа базы данных и передача его содержимого в MySQL для восстановления базы данных
gzip -dc $DIR/$DUMP_FILE | mysql --user=$USER --password=$PASS $DB
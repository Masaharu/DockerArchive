#!/usr/bin/bash

# Hive用metastore DBインスタンス削除
mysql -uroot -pmysql < ../sqls/drop_metastore_db.sql

# MariaDBの停止・無効化
sudo systemctl stop mariadb
sudo systemctl disable mariadb

# データベースファイル削除
sudo rm -rf /var/lib/mysql


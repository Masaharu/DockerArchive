#!/usr/bin/bash

# データベースファイル作成 
sudo mysql_install_db --user=mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 777 /var/log/mariadb

# MariaDBの起動
sudo systemctl start mariadb

# データベースの初期設定
mysql_secure_installation < ./mariadb_secure.conf

# MariaDB自動起動設定
sudo systemctl enable mariadb

# Hive用metastore DBインスタンス作成
mysql -uroot -pmysql < ../sqls/create_metastore_db.sql

# Hive用データベーススキーマの作成
schematool -dbType mysql -initSchema

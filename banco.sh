#!/bin/bash

apt -y update
sudo apt -y install mysql-server

sudo mysql <<EOF
CREATE DATABASE wordpress;
CREATE USER 'wp_admin'@'%' IDENTIFIED BY 'root';
GRANT ALL ON wordpress.* TO 'wp_admin'@'%';
FLUSH PRIVILEGES;
EOF

sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i 's/skip-external-locking/#skip-external-locking/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

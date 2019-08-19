#!/usr/bin/env bash

set -e

sudo apt update && sudo apt install -y mariadb-server

echo "######################################################"
echo "Setting up MySQL database, your input will be required"
echo "######################################################"

sudo /usr/bin/mysql_secure_installation
sudo systemctl restart mysql

echo "Database configuration required"

# Open database and configure
echo "######################################################"
echo "        Enter the password for root mysql user        "
echo "######################################################"
sudo mysql -u root -p

echo "######################################################"
echo "         Enter the password for roundcube user        "
echo "######################################################"
sudo mysql -u roundcube -p roundcubemail < ~/webfiles/roundcube/SQL/mysql.initial.sql

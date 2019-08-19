#!/usr/bin/env bash

# Stop if any command fails
set -e

PHP_VERSION="7.3" # Set the PHP version number used

sudo apt update && sudo apt install ca-certificates apt-transport-https gnupg
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ buster main" | sudo tee /etc/apt/sources.list.d/php.list

sudo apt update && sudo apt install -y php php-fpm php-json php-xmlrpc php-curl php-gd php-xml php-mbstring php-mysql

# PHP Configuration
sudo mv /etc/php/${PHP_VERSION}/fpm/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf.ORIG
sudo mv /etc/php/${PHP_VERSION}/fpm/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini.ORIG
sudo mkdir /var/run/php-fpm
sudo mkdir -p /usr/share/nginx/cache/fcgi

cd php/
sudo cp php.ini /etc/php/${PHP_VERSION}/fpm/
sudo cp php-fpm.conf /etc/php/${PHP_VERSION}/fpm/
sudo cp www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/
sudo cp wordpress.conf /etc/php/${PHP_VERSION}/fpm/pool.d/

touch ~/logs/phpfpm_error.log
sudo systemctl restart php${PHP_VERSION}-fpm

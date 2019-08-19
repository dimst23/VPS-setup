#!/usr/bin/env bash

set -e

# Setup constants
USER="username"

FOLDER_DIR=$(pwd)

echo "#################################################"
echo "         Server configuration installation       "
echo "#################################################"

# Create the SWAP file and activate it
sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# System configuration files
cp vimrc ~/.vimrc && sudo cp vimrc /root/.vimrc
cp bashrc ~/.bashrc
sudo cp logrotate/auth /etc/logrotate.d/

# Update repos and move on
sudo apt update
sudo apt install -y htop curl git dpkg-dev gnupg curl
mkdir -p ~/webfiles/letsencrypt && mkdir ~/logs

# Apt repo keys installation
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
wget --quiet -O - http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key | sudo apt-key add -
wget --quiet -O - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash

# Copy sources files
sudo cp repo_list/* /etc/apt/sources.list.d/ && sudo apt update

# Download the necessary files
wget https://wordpress.org/latest.tar.gz -O wordpress.tar.gz
wget https://github.com/roundcube/roundcubemail/releases/download/1.3.9/roundcubemail-1.3.9-complete.tar.gz -O roundcube.tar.gz

# Extract the downloaded files
tar xvf wordpress.tar.gz && mv wordpress/ ~/webfiles
tar xvf roundcube.tar.gz && mv roundcubemail-1.3.9/ ~/webfiles/roundcube
rm -rf *.tar.gz

# Change correct permissions
cd ~/webfiles && sudo chown -R ${USER}:www-data .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
#chmod 640 wordpress/wp-config.php

# Call the installation scripts
cd ${FOLDER_DIR}
./mysql/mysql.sh
./php/php.sh
./nginx/nginx.sh

# Fail2Ban Configuration
./fail2ban/fail2ban.sh

# Mail server installation
./mail/mail.sh

# ZSH Configuration
./zsh/zsh.sh

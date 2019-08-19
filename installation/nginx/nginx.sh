#!/usr/bin/env bash

set -e

# Latest stable OpenSSL branch
BRANCH_NAME="OpenSSL_1_1_1-stable"
FOLDER_DIR=$(pwd)

echo "###########################################"
echo "             Installing Nginx              "
echo "###########################################"
sudo apt update && cd /usr/local/src

sudo mkdir /usr/local/src/nginx && cd /usr/local/src/nginx/
sudo apt source nginx && cd ../ && sudo git clone https://github.com/openssl/openssl.git

cd openssl/ && sudo git checkout ${BRANCH_NAME} && cd ../nginx/nginx-*/

# Add necessary configuration parameters for the build
sudo sed -i '/--with-ld-opt="$(LDFLAGS)"/a --with-openssl=/usr/local/src/openssl' debian/rules
sudo sed -i 's/dh_shlibdeps -a/dh_shlibdeps -a --dpkg-shlibdeps-params=--ignore-missing-info/g' debian/rules
sudo sed -i 's/CFLAGS="$CFLAGS -Werror"/#CFLAGS="$CFLAGS -Werror"/g' auto/cc/gcc

# Build and install the package
sudo apt build-dep nginx -y && sudo dpkg-buildpackage -b && cd ../
sudo dpkg -i nginx_*.deb && sudo systemctl unmask nginx && sudo apt-mark hold nginx && sudo rm -rf nginx-d* nginx_*.deb

# Configuration files (before certbot)
cd ${FOLDER_DIR}/nginx/
sudo rm -rf /etc/nginx/conf.d/* && sudo cp conf.d/redirect.conf /etc/nginx/conf.d/
sudo systemctl restart nginx

# Certbot certificate creation
.././certbot/certbot.sh

# Configuration files (after certbot)
sudo cp -r config/ conf.d/ nginx.conf /etc/nginx

# Service restart before proceeding
sudo systemctl restart nginx

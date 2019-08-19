#!/usr/bin/env bash

# Useful links
# https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf
# https://www.digitalocean.com/community/tutorials/how-to-configure-a-mail-server-using-postfix-dovecot-mysql-and-spamassassin
# https://www.linuxbabe.com/mail-server/install-roundcube-webmail-ubuntu-16-04-nginx-mariadb-php7

set -e

# Install the required packages
sudo apt update && sudo apt install -y postfix postfix-policyd-spf-python dovecot-core dovecot-imapd opendkim opendkim-tools

# Copy the configuration files over to the required folders
cd mail/
sudo mv /etc/postfix/main.cf /etc/postfix/main.cf.ORIG && sudo mv /etc/postfix/master.cf /etc/postfix/master.cf.ORIG
sudo cp -r postfix_config/* /etc/postfix
sudo cp -r dovecot_config/* /etc/dovecot/conf.d/

# SPF and DKIM Configuration
sudo gpasswd -a postfix opendkim # Add the opendkim user to postfix
sudo cp opendkim.conf /etc/ && sudo mkdir /etc/opendkim && sudo mkdir /etc/opendkim/keys

echo 'echo "*@domain.com    default._domainkey.domain.com" > /etc/opendkim/signing.table' | sudo bash
echo 'echo "default._domainkey.domain.com     domain.com:default:/etc/opendkim/keys/domain.com/default.private" > /etc/opendkim/key.table' | sudo bash
sudo cp trusted.hosts /etc/opendkim/trusted.hosts

# Generate DKIM keys
sudo mkdir /etc/opendkim/keys/domain.com/
sudo opendkim-genkey -b 4096 -d domain.com -D /etc/opendkim/keys/domain.com -s default -v

# Change the permissions
sudo chown -R opendkim:opendkim /etc/opendkim && sudo chmod go-rw /etc/opendkim/keys

# Generate DH parameters
sudo openssil dhparam -out /etc/dovecot/dh.pem

# Configuration for postfix
sudo mkdir /var/spool/postfix/opendkim && sudo chown opendkim:postfix /var/spool/postfix/opendkim

# Create the databases
sudo postmap /etc/postfix/virtual
sudo postmap /etc/postfix/sasl/sasl_passwd

# Show the DNS record configuration
echo "##################################################"
echo "          DKIM DNS record configuration           "
echo "##################################################"
sudo cat /etc/opendkim/keys/domain.com/default.txt

# Restart the services
sudo systemctl restart postfix dovecot opendkim

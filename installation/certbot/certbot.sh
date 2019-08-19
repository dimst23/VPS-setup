#!/usr/bin/env bash

set -e

sudo apt update && sudo apt install -y certbot

# Get the certificates
sudo certbot certonly --cert-name domain.com --email admin@domain.com --webroot -w /webroot -d domain.com,www.domain.com --rsa-key-size 4096 --preferred-challenges http-01 --must-staple

# Set the cronjob for autorenewal
sudo crontab -l > cron_jobs
echo '14 5 * * * /usr/bin/certbot renew -w /webroot --quiet --post-hook "/usr/bin/systemctl restart nginx"' >> cron_jobs
sudo crontab cron_jobs && rm -rf cron_jobs

# Generate the dhparameters
sudo openssl dhparam -out /etc/nginx/dhparams.pem 4096



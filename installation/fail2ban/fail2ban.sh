#!/usr/bin/env bash

set -e

sudo apt update && sudo apt install -y fail2ban

cd fail2ban/
sudo cp filters/* /etc/fail2ban/filter.d/ && sudo cp jail.local /etc/fail2ban
sudo systemctl restart fail2ban

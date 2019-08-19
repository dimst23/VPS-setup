#!/usr/bin/env bash

set -e

echo "#######################################################"
echo "                 ZSH Configuration                     "
echo "#######################################################"

sudo apt update
sudo apt install zsh tmux

# Download Oh My Zsh and change the default shell for the user
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s /usr/bin/zsh dimitris

# Install plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

ln -sf "$(pwd)/zsh/zshrc ~/.zshrc"

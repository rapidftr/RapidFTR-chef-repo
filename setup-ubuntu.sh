#!/bin/bash

echo "Updating apt package index..."
sudo apt-get --yes update

echo "Installing chef's required apt packages..."
sudo apt-get --yes install build-essential wget ssl-cert libreadline6 libreadline6-dev openssl libssl-dev zlib1g zlib1g-dev

echo "Installing Ruby"
sudo apt-get --yes install ruby1.8 rubygems1.8 rdoc1.8 ruby1.8-dev

echo "Installing chef..."
sudo gem install chef --version 0.10.8 --no-rdoc --no-ri

# echo "Setting up chef-solo..."
# sudo env SSL_CRT=$SSL_CRT SSL_KEY=$SSL_KEY FQDN=$FQDN CHEF_ROLE=$CHEF_ROLE ruby $CHEF_REPO_ROOT/setup/setup-chef-solo-config.rb

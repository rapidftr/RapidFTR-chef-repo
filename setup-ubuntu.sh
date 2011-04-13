#!/bin/bash

RUBYGEMS_VERSION=1.7.2
CHEF_REPO_ROOT=`dirname $0`

echo "Updating apt package index..."
sudo apt-get update

echo "Installing chef's required apt packages..."
sudo apt-get install ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert

echo "Installing rubygems $RUBYGEMS_VERSION from source..."
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-$RUBYGEMS_VERSION.tgz
tar zxf rubygems-$RUBYGEMS_VERSION.tgz
cd rubygems-$RUBYGEMS_VERSION
sudo ruby setup.rb --no-format-executable

echo "Installing chef..."
sudo gem install chef

echo "Setting up chef-solo..."
ruby $CHEF_REPO_ROOT/setup/setup-chef-solo-config.rb

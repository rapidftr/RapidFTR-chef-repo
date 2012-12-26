#!/bin/bash

RUBY_VERSION=1.8.7-p358
RUBYGEMS_VERSION=1.8.21
CHEF_VERSION=10.16.4

INITIAL_DIR=`pwd`
cd `dirname $0`
CHEF_REPO_ROOT=`pwd`
cd $INITIAL_DIR

echo "Updating apt package index..."
sudo apt-get --yes update

echo "Installing chef's required apt packages..."
sudo apt-get --yes install build-essential wget ssl-cert libreadline6 libreadline6-dev openssl libssl-dev zlib1g zlib1g-dev

echo "Installing ruby $RUBY_VERSION from source..."
cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-$RUBY_VERSION.tar.gz
tar xzf ruby-$RUBY_VERSION.tar.gz
cd ruby-$RUBY_VERSION
./configure
make
sudo make install

echo "Installing rubygems $RUBYGEMS_VERSION from source..."
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-$RUBYGEMS_VERSION.tgz
tar zxf rubygems-$RUBYGEMS_VERSION.tgz
cd rubygems-$RUBYGEMS_VERSION
sudo ruby setup.rb --no-format-executable

echo "Installing chef..."
sudo gem install chef --version $CHEF_VERSION --no-rdoc --no-ri

echo "Setting up chef-solo..."
sudo env SSL_CRT=$SSL_CRT SSL_KEY=$SSL_KEY FQDN=$FQDN CHEF_ROLE=$CHEF_ROLE ruby $CHEF_REPO_ROOT/setup/setup-chef-solo-config.rb

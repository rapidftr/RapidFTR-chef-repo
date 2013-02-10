#!/bin/bash

sudo groupadd nobody

echo "Updating apt package index..."
sudo add-apt-repository ppa:longsleep/couchdb
sudo apt-get --yes update

echo "Installing required packages..."
sudo apt-get --yes install ruby1.8 rubygems1.8 libxml2-dev libxslt1-dev build-essential git openjdk-7-jdk imagemagick openssh-server couchdb
sudo REALLY_GEM_UPDATE_SYSTEM=yes gem update --system

echo "Installing bundler"
sudo gem install bundler --no-rdoc --no-ri

echo "Installing gems"
sudo bundle install --deployment

echo "Fix moneta error"
sudo gem uninstall moneta
sudo gem install moneta --version 0.6.0

echo "Installing recipes"
librarian-chef install

#
# Cookbook Name:: rapid_ftr
# Recipe:: default
#
# Copyright 2010, Dave Cameron
#
# All rights reserved - Do Not Redistribute
#
package "default-jre-headless"
package "libxml2-dev"
package "libxslt1-dev"
package "imagemagick"
gem_package "rake"
gem_package "bundler"

directory "/srv/rapid_ftr/shared" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

directory "/srv/rapid_ftr/shared/log" do
  owner "nobody"
  group "admin"
  mode "0755"
  recursive true
  action :create
end

directory "/srv/rapid_ftr/shared/config" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

directory "/srv/rapid_ftr/shared/system" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

directory "/srv/rapid_ftr/shared/system/bb-builds" do
  owner "root"
  group "admin"
  mode "0775"
  recursive true
  action :create
end

cookbook_file "/etc/init.d/solr" do
  source "solr.init"
  owner "root"
  group "root"
  mode "0744"
end

service "solr" do
  supports :restart => true
  action [:enable, :start]
end

deploy_revision "/srv/rapid_ftr" do
  repo "https://github.com/RapidFTR-Uganda/RapidFTR.git"
  revision "release"
  user "root"
  enable_submodules true
  migrate true
  migration_command "/usr/bin/bundle install"
  environment "RAILS_ENV" => "production"
  shallow_clone true
  action :deploy
  restart_command "touch tmp/restart.txt"
  symlinks(
    "system" => "public/system",
    "log" => "log",
    "system/bb-builds/latest" => "public/blackberry")
  symlink_before_migrate nil # to skip database.yml
end

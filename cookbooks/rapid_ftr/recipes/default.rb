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

directory "/srv/rapid_ftr/shared/config/initializers" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

file "/srv/rapid_ftr/shared/config/initializers/hoptoad.rb" do
  action :touch # in case one with a proper api_key isn't in place.
  owner "root"
  group "root"
  mode "0644"
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
  group "admin" # so the script to copy a new build doesn't have to sudo.
  mode "0775"
  recursive true
  action :create
end

deploy_revision "/srv/rapid_ftr" do
  repo node[:rapid_ftr][:repository]
  revision node[:rapid_ftr][:revision]
  user "root"
  enable_submodules true
  migrate true
  migration_command "/usr/bin/bundle install"
  environment "RAILS_ENV" => "production"
  shallow_clone true
  action :deploy
  restart_command "touch tmp/restart.txt"
  purge_before_symlink %w(
    log
    tmp/pids
    public/system
    config/initializers/hoptoad.rb
    )
  symlinks(
    "system" => "public/system",
    "log" => "log",
    "system/bb-builds/latest" => "public/blackberry",
    "config/initializers/hoptoad.rb" => "config/initializers/hoptoad.rb")
  symlink_before_migrate nil # to skip database.yml
end

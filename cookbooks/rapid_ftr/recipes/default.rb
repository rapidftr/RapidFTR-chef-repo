#
# Cookbook Name:: rapid_ftr
# Recipe:: default
#
# Copyright 2010, Dave Cameron
#
# All rights reserved - Do Not Redistribute
#

directory "/srv/rapid_ftr/shared" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

deploy "/srv/rapid_ftr" do
  repo "https://github.com/jorgej/RapidFTR.git"
  revision "HEAD" # or "HEAD" or "TAG_for_1.0" or (subversion) "1234"
  user "root"
  enable_submodules true
  migrate true
  migration_command "rake db:migrate"
  environment "RAILS_ENV" => "production"
  shallow_clone true
  action :deploy
  restart_command "touch tmp/restart.txt"
end

require 'rubygems'

passenger = node[:passenger][:production]
passenger_path = passenger[:path]
ssl_path = File.join passenger_path, "conf", "ssl"

directory ssl_path do
  owner "nobody"
  group "root"
  mode 0775
end

cookbook_file File.join(ssl_path, "server.crt") do
  owner "nobody"
  group "root"
  mode 0440
end

cookbook_file File.join(ssl_path, "server.key") do
  owner "nobody"
  group "root"
  mode 0440 # Make private key non-readable and non-writable
end

template "#{passenger_path}/conf/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :passenger_root => "##PASSENGER_ROOT##",
    :ruby_path => "##RUBY_PATH##",
    :pidfile => File.join(passenger_path, "nginx.pid"),
    :passenger => passenger
  )
end

bash "config_patch" do
  # The big problem is that we can't compute the gem install path
  # because we don't know what ruby version we're being installed
  # on if RVM is present.
  # only_if "grep '##PASSENGER_ROOT##' #{nginx_path}/conf/nginx.conf"
  user "root"
  code "#{passenger_path}/sbin/config_patch.sh #{passenger_path}/conf/nginx.conf"
  notifies :restart, 'service[passenger]'
end

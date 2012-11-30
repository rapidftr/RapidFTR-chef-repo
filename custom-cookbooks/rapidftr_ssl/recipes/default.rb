passenger = node[:passenger][:production]
passenger_path = passenger[:path]
ssl = node[:rapidftr_ssl]

directory File.join(passenger_path, "ssl") do
  owner "root"
  group "root"
  mode 0755
end

cookbook_file File.join(passenger_path, ssl[:certificate]) do
  owner "root"
  group "root"
  mode 0644
end

cookbook_file File.join(passenger_path, ssl[:key]) do
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
    :passenger_path => exec("passenger-config --root").chomp,
    :ruby_path => exec("which ruby").chomp,
    :pidfile => File.join(passenger_path, "nginx.pid"),
    :passenger => passenger,
    :ssl => ssl
  )
end

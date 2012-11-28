include_recipe "rapid_ftr::base"

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

directory "/srv/rapid_ftr/shared/system" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

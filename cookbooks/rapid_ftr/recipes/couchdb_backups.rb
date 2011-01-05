cookbook_file "/etc/init.d/couchdb_backups" do
  source "couchdb_backups.init"
  owner "root"
  group "root"
  mode "0755"
end

service "couchdb_backups" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :start]
end

%w{ rapidftr_form_section_production rapidftr_user_production rapidftr_sessions_production rapidftr_suggested_field_production rapidftr_contact_information_production rapidftr_child_production }.each do |db|
  # this needs to be conditional, based on whether the database already exists
  # http_request "rapidftr_form_section_production" do
  #   action :put
  #   url "http://localhost:5984/#{db}/"
  # end
end

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

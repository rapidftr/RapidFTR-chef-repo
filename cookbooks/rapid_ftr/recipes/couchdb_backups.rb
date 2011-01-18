# Note this assumes the backup databases already exist.
# We could handle that here or it could be handled inside couchdb_replicate.rb.

cookbook_file "/usr/bin/couchdb_replicate.rb" do
  source "couchdb_replicate.rb"
  owner "root"
  group "root"
  mode "0755"
end

databases = %w(
  rapidftr_child_production
  rapidftr_form_section_production
  rapidftr_user_production
  rapidftr_sessions_production
  rapidftr_contact_information_production
  rapidftr_suggested_field_production
  )

cron "replicate_every_five_minutes" do
  command "/usr/bin/couchdb_replicate.rb -s admin@uganda.rapidftr.com -i /home/admin/.ssh/id_rsa -d #{databases.join(',')}"
  mailto "jhume@thoughtworks.com,jorgejust@gmail.com"
  minute "*/5"
end

# The original attempt using continuous replication, which we couldn't get working with Nginx providing SSL.
# Note service is stopped/disabled.
cookbook_file "/etc/init.d/couchdb_backups" do
  source "couchdb_backups.init"
  owner "root"
  group "root"
  mode "0755"
end

service "couchdb_backups" do
  supports :start => true, :stop => true, :restart => true
  action [:stop, :disable]
end

RapidFTR Chef Setup
===================

This was originally set up for the Uganda deployment and used the Opscode platform. We're now working on getting it in shape to be usable via chef-solo.

Here are the manual steps that should be required:

	# If you're logged in as root and don't yet have an admin account (likely on Linode):
	adduser admin
	# Provide a strong password. You can leave everything else blank.
	usermod -a -G sudo admin
	
	# Now log out and log back in as admin.
	# TODO: remove root's ability to log in?
	
	# Download and untar
	wget --no-check-certificate https://github.com/downloads/duelinmarkers/RapidFTR-chef-repo/chef-repo-3226f1.tgz
	tar xzf chef-repo-3226f1.tgz
	cd chef-repo/
	sudo ./setup-ubuntu.sh
	# Say yes when prompted to install packages.
	# Respond to prompts for SSL certificate files with reasonable locations.
	# If you haven't already, copy SSL certificate files into those locations.
	sudo chef-solo
	# Get a cup of tea and a biscuit or two. This takes ages.
	sudo /etc/init.d/solr start # We don't know why this is necessary.
	cd /srv/rapid_ftr/current
	sudo rake couchdb:create db:seed RAILS_ENV=production

-------------------------------------------------------
Here are the manual steps required previously. 

	# Start with a plain Linux install
	sudo apt-get update
	# sudo apt-get upgrade # is that really needed? Shouldn't update be enough?
	
	# Install Ruby
	sudo apt-get install ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert
	
	# and rubygems
	cd /tmp
	wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
	tar zxf rubygems-1.3.7.tgz
	cd rubygems-1.3.7
	sudo ruby setup.rb --no-format-executable
	
	# Install chef
	sudo gem install chef --no-rdoc --no-ri
	
	# Put SSL certificates in place
	scp admin@uganda.rapidftr.com:/home/admin/concatenated.dev.rapidftr.com.crt ~
	scp admin@uganda.rapidftr.com:/home/admin/dev.rapidftr.com.key ~
	
	# Write these config files:
	
	# /etc/chef/solo.rb
	file_cache_path "/tmp/chef-solo"
	cookbook_path "/tmp/chef-solo/cookbooks"
	json_attribs "/etc/chef/node.json"
	recipe_url "https://github.com/downloads/duelinmarkers/RapidFTR-chef-repo/chef-repo.tgz"
	# role_path "/var/chef-solo/roles"
	
	# /etc/chef/node.json
	{
		"rapid_ftr":{
			"ssl_certificate": "/home/rapidftr/concatenated.dev.rapidftr.com.crt",
			"ssl_certificate_key": "/home/rapidftr/dev.rapidftr.com.key"
			},
			"passenger":{
				"production":{
					"bins_path": "/usr/bin"
				}
			},
		"run_list": [
			"recipe[build-essential::default]",
			"recipe[passenger::daemon]",
			"recipe[erlang::default]",
			"recipe[couchdb::default]",
			"recipe[git::default]",
			"recipe[rapid_ftr::default]"]
	}

# run chef-solo

# First time failed with:
[Tue, 01 Mar 2011 22:36:06 -0500] ERROR: package[libcurl4-openssl-dev] (/tmp/chef-solo/cookbooks/passenger/recipes/daemon.rb:10:in `from_file') had an error:
apt-get -q -y install libcurl4-openssl-dev=7.21.0-1ubuntu1 returned 100, expected 0
# because I hadn't updated packages, apparently. After a long slow update that package installed fine.

# Then failed with:
/usr/lib/ruby/gems/1.8/gems/chef-0.9.12/bin/../lib/chef/mixin/command.rb:184:in `handle_command_failures': /etc/init.d/couchdb restart returned 1, expected 0 (Chef::Exceptions::Exec)
# But couch is running and looks fine. Manual sudo /etc/init.d/couchdb restart succeeded happily.

# Then set up the database.
sudo rake couchdb:create db:seed RAILS_ENV=production

# Then the app worked except for search because the solr service wasn't running.
# Restarted the machine, then solr was running and things looked good.
# If children were inserted and not indexed, then
cd /srv/rapid_ftr/current
script/console
	then Child.reindex!


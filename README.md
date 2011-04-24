# RapidFTR Chef Repo #

This code supports automated deployment for [RapidFTR](http://rapidftr.com/). It's targeted at enabling anyone with a Linux server to set up their own production-ready instance of RapidFTR with as little manual setup as possible. The implementation is [chef](http://www.opscode.com/chef/)-based, utilizing chef-solo.

At the moment automated deployment is only tested on Ubuntu, but we're interested (to one degree or another) in supporting other Linux distributions and POSIX OSs. (If you want to test and add support for another, see "Contributing" and "Other Platforms" below.)

The most up-to-date version of this code is currently at <https://github.com/duelinmarkers/RapidFTR-chef-repo>.

The RapidFTR server application repository can be found at <https://github.com/jorgej/RapidFTR>.

If you have any questions about anything here, please ask on the RapidFTR Google Group: <http://groups.google.com/group/rapidftr>

## Usage ##

Here are the steps required for a production deployment:

Start with a publicly accessible server (or one that will be made publicly accessible). (Linode and Amazon EC2 are both good for this.)

*	SSH into your server:

*	If you're logged in as root and don't yet have an admin account (which is likely on Linode but not otherwise):

		adduser admin # When prompted, provide a strong password. You can leave everything else blank.
		usermod -a -G sudo admin
	
	*	Now log out and log back in as admin.
	*	TODO: remove root's ability to log in?

* Now download and untar this repository.

		wget --no-check-certificate https://github.com/downloads/duelinmarkers/RapidFTR-chef-repo/chef-repo-3226f1.tgz
		tar xzf chef-repo-3226f1.tgz
		cd chef-repo/
		sudo ./setup-ubuntu.sh

	*	Say yes when prompted to install packages.

	*	Respond to prompts for SSL certificate files with reasonable locations.

*	If you haven't already, copy SSL certificate files into the locations.

*	Now run chef-solo to install the application and its dependencies.

		sudo chef-solo # This will take an uncomfortably long time (ie, more than 10 minutes).
		sudo /etc/init.d/solr start # This is necessary due to a bug. You could also just reboot.
		cd /srv/rapid_ftr/current
		sudo rake couchdb:create db:seed RAILS_ENV=production

You should be all set. Open your browser to https://YOURSERVER/ and login with username and password "rapidftr." If you're really planning to use this instance, change your username and password now.

## Contributing ##

We use bundler and rvm to control the ruby environment we are developing in. These instructions will assume that you have already installed rvm (<https://rvm.beginrescueend.com/rvm/install/>).

To develop on the deployment platform:

*	Clone this repository.

    git clone https://github.com/duelinmarkers/RapidFTR-chef-repo.git

* Set up the rvm gemset we expect, and cd in to your clone. You should see a message from rvm prompting you to accept our ruby interpreter version and gemset.

    rvm gemset create RapidFTR-chef-repo
    cd RapidFTR-chef-repo

*	Run bundler. (rvm adds the bundler gem to gemsets by default, so you should have it already.)

		bundle install

* Add the vagrant box that we use as our VM base. There's more info about boxes on Vagrant's site (<http://vagrantup.com/docs/getting-started/boxes.html>).

    vagrant box add lucid32 http://files.vagrantup.com/lucid32.box

* Create the VM and run the tests against it.

    cd test
		rake full

	That will boot up a virtual machine running Ubuntu, "provision" the machine using the chef-repo rooted one directory up from the test directory (ie, using your working copy of the cookbooks), and run test/*_spec.rb. This can take a while, but may need some input to approve network access the first-time, depending on your firewall setup. 

*	Run just:

		rake

	to re-run the tests if you've made manual changes in the tests or the server.

*	Run

		rake reprovision

	to re-run your local cookbooks on the running VM. (Note that won't start from a clean state, but since starting from a clean state takes a long time it might be worthwhile for faster feedback.)

The (very slim) spec suite that lives in the test directory is ultimately intended to be runnable against a fresh production deployment and provide a "smoke test." For now it only works locally against the Vagrant VM.

## Why Chef Solo? ##

We use chef-solo because usage of chef-server (or the Opscode Platform) assumes central management of servers, whereas it's a goal of RapidFTR that anyone should be able to set up their own instance.

## Other Platforms ##

Many of the chef cookbooks we used as starting points had built in support for several Linux variants, including Ubuntu, Debian, Fedora, and RHEL. We've only tested deployment on Ubuntu, so it's possible we've broken the support those cookbooks offered. We've also created custom recipes that so far make no effort to work on anything other than Ubuntu.

If you want to add support for another OS, feel free to fork the repository and issue pull requests once things are working. Ideally we'd like to verify compatibility with automated tests that deploy to an image of your target OS (maybe using Vagrant). Otherwise we can't know it's working and won't know if we accidentally break it.


---

Here are the manual steps previously required for production deployment.

These will be removed once the automated deployment is a little more mature.

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

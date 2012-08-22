# RapidFTR Chef Repo #

This code supports automated deployment for [RapidFTR](http://rapidftr.com/). It's targeted at enabling anyone with a Linux server to set up their own production-ready instance of RapidFTR with as little manual setup as possible. The implementation is [chef](http://www.opscode.com/chef/)-based, utilizing chef-solo.

At the moment automated deployment is only tested on Ubuntu, but we're interested in supporting other Linux distributions and POSIX OSs. (If you want to test and add support for another, see "Contributing" and "Other Platforms" below.)

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

		wget --no-check-certificate https://github.com/downloads/duelinmarkers/RapidFTR-chef-repo/chef-repo-e58a0cc.tgz
		mkdir chef-repo
		cd chef-repo
		tar xzf ../chef-repo-e58a0cc.tgz
		sudo ./setup-ubuntu.sh

	*	Say yes when prompted to install packages.

	*	Respond to prompts for SSL certificate files with reasonable locations.

*	If you haven't already, copy SSL certificate files into the locations. See below for help generating a certificate.

*	Now run chef-solo to install the application and its dependencies.

		sudo chef-solo # This will take an uncomfortably long time (ie, more than 10 minutes).

You should be all set. Open your browser to https://YOURSERVER/ and login with username and password "rapidftr." If you're really planning to use this instance, change your username and password now.

## Generating an SSL certificate

This page has instructions for creating and self-signing a certificate: http://www.akadia.com/services/ssh_test_certificate.html

Briefly, here are the commands we've used:

		openssl genrsa -des3 -out test.key 1024                        # generate private key
		openssl req -new -key test.key -out test.csr   # generate certificate signing request
		cp test.key test.key.org
		openssl rsa -in test.key.org -out test.key               # remove passphrase from key
		openssl x509 -req -days 365 -in test.csr -signkey test.key -out test.crt  # self-sign

## Contributing ##

We use bundler and rvm to control the ruby environment we are developing in. These instructions will assume that you have already installed rvm (<https://rvm.beginrescueend.com/rvm/install/>).

To develop on the deployment platform:

*	Clone this repository.

		git clone https://github.com/duelinmarkers/RapidFTR-chef-repo.git

* Set up the rvm gemset we expect, and cd in to your clone. You should see a message from rvm prompting you to accept our ruby interpreter version and gemset.

		rvm install 1.8.7-p302 # if you don't have it
		rvm use 1.8.7
		rvm gemset create RapidFTR-chef-repo
		cd RapidFTR-chef-repo

*	Run bundler. (rvm adds the bundler gem to gemsets by default, so you should have it already.)

		bundle install

* Add the vagrant box that we use as our VM base. There's more info about boxes on Vagrant's site (<http://vagrantup.com/docs/getting-started/boxes.html>).

		vagrant box add lucid32 http://files.vagrantup.com/lucid32.box

* Create the VM and run the tests against it.

		rake vagrant:full

	That will boot up a virtual machine running Ubuntu, "provision" the machine using the chef-repo rooted one directory up from the test directory (ie, using your working copy of the cookbooks), and run test/*_spec.rb. This can take a while, but may need some input to approve network access the first-time, depending on your firewall setup. 

*	Run:

		rake vagrant:setup\_ssh system\_spec

	to re-run the tests if you've made manual changes in the tests or the server.

*	Run

		rake vagrant:reprovision

	to re-run your local cookbooks on the running VM. (Note that won't start from a clean state, but since starting from a clean state takes a long time it might be worthwhile for faster feedback.)

## Testing on EC2 ##

For a more realistic test, you can use Amazon EC2. Set up the following environment variables:

*	AMAZON\_ACCESS\_KEY\_ID
*	AMAZON\_SECRET\_ACCESS\_KEY
*	RAPID\_FTR\_IDENTITY\_FILE

## Why Chef Solo? ##

We use chef-solo because usage of chef-server (or the Opscode Platform) assumes central management of servers, whereas it's a goal of RapidFTR that anyone should be able to set up their own instance.

## Other Platforms ##

While we've developed for and tested on Ubuntu 10.04, we want RapidFTR to work on other Linux distributions. We've created continuous integration builds using other AMIs, but at this time no one has yet undertaken the work to get things passing. See the [RapidFTR Deployment continuous integration builds](http://ci.rapidftr.com:8111/project.html?projectId=project3&tab=projectOverview) for current state.



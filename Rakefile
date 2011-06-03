begin
  require 'rspec/core/rake_task'
rescue LoadError
  puts "\nRspec 2 is required.\nMaybe you need a bundle install."
  raise
end

desc "Run system specs on an existing instance."
task :default => %w( vagrant:setup_ssh system_spec )

vagrant_dir = File.join(File.dirname(__FILE__), 'test/vagrant')

namespace :vagrant do

  desc "Deploy fresh instance and run system specs."
  task :full => %w( vagrant:deploy vagrant:setup_ssh system_spec )

  desc "Deploy a fresh vagrant instance (destroying an existing instance)."
  task :deploy do
    cd vagrant_dir do
      sh 'vagrant destroy'
      sh 'vagrant up'
    end
  end

  task :destroy do
    cd vagrant_dir do
      sh 'vagrant destroy'
    end
  end

  desc "Re-provision running instance from local chef cookbooks."
  task :reprovision do
    cd vagrant_dir do
      sh 'vagrant provision'
    end
  end

  task :setup_ssh do
    cd vagrant_dir do
      sh "vagrant ssh_config > vagrant.ssh.config"
      ENV['SSH_OPTIONS'] = "-F #{File.expand_path('vagrant.ssh.config')}"
      ENV['SSH_HOST'] = "vagrant"
    end
  end
end

desc "Run specs to check the health of a system. No dependencies defined here because you might want vagrant, EC2, or some other instance pointed to by SSH_OPTIONS and SSH_HOST."
RSpec::Core::RakeTask.new('system_spec') do |t|
  t.rspec_opts = ["--color", "--format documentation", "--require ./test/spec_helper.rb"]
  t.pattern = 'test/*_spec.rb'
end

task :create_archive do
  sh %(tar czf ../RapidFTR-chef-repo-test.tgz *)
end

namespace :ec2 do
  require 'AWS'
  require 'pry'

  desc "Provision a fresh instance, deploy, run system specs, and terminate. Set INTERACTIVE=true to play with the instance before termination."
  task :full => %w( create_archive ec2:ami:from_env ) do
    with_ec2_instance do |instance|
      wait 10, "because otherwise sometimes we can't ssh in just yet"
      retrying 3 do
        sh %(scp #{ENV['SSH_OPTIONS']} ../RapidFTR-chef-repo-test.tgz #{ENV['SSH_HOST']}:)
      end
      sh %(scp #{ENV['SSH_OPTIONS']} #{vagrant_dir}/localhost.rapidftr.test.crt #{ENV['SSH_HOST']}:)
      sh %(scp #{ENV['SSH_OPTIONS']} #{vagrant_dir}/localhost.rapidftr.test.key #{ENV['SSH_HOST']}:)
      sh %(ssh #{ENV['SSH_OPTIONS']} #{ENV['SSH_HOST']} "mkdir chef-repo")
      sh %(ssh #{ENV['SSH_OPTIONS']} #{ENV['SSH_HOST']} "tar xzf RapidFTR-chef-repo-test.tgz --directory chef-repo")
      sh %(ssh #{ENV['SSH_OPTIONS']} #{ENV['SSH_HOST']} "cd chef-repo/ && sudo env SSL_CRT=/home/ubuntu/localhost.rapidftr.test.crt SSL_KEY=/home/ubuntu/localhost.rapidftr.test.key FQDN=#{instance.dnsName} ./setup-ubuntu.sh")
      sh %(ssh #{ENV['SSH_OPTIONS']} #{ENV['SSH_HOST']} "sudo chef-solo")
      Rake::Task['system_spec'].invoke
      binding.pry if interactive?
    end
  end

  desc "Provision a fresh instance and get interactive with it."
  task :up_and_down do
    raise "INTERACTIVE is not 'true'! That's all this task is for." unless interactive?
    with_ec2_instance do |instance|
      puts "Instance up."
      binding.pry
    end
  end

  namespace :ami do
    KNOWN_AMIS = {
      'ubuntu_8.04'  => {:ami => 'ami-6836dc01', :ssh_user => 'ubuntu', :description => 'Ubuntu 8.04 LTS Hardy instance store'},
      'ubuntu_10.04' => {:ami => 'ami-7000f019', :ssh_user => 'ubuntu', :description => 'Ubuntu 10.04 LTS Lucid instance store'},
      'ubuntu_10.10' => {:ami => 'ami-a6f504cf', :ssh_user => 'ubuntu', :description => 'Ubuntu 10.10 Maverick instance store'},
      'ubuntu_11.04' => {:ami => 'ami-e2af508b', :ssh_user => 'ubuntu', :description => 'Ubuntu 11.04 Natty instance store'},
      'debian_4.0'   => {:ami => 'ami-def615b7', :ssh_user => 'root', :description => 'Debian 4.0 Etch instance-store'},
      'debian_5.0'   => {:ami => 'ami-dcf615b5', :ssh_user => 'root', :description => 'Debian 5.0 Lenny instance-store'},
      'fedora_14'    => {:ami => 'ami-669f680f', :ssh_user => 'ec2-user', :description => 'Fedora 14 instance store'}
    }

    DEFAULT_AMI = KNOWN_AMIS['ubuntu_10.04']

    KNOWN_AMIS.each_pair do |name, attributes|
      desc "Use #{attributes[:description]}."
      task name do
        puts "Using #{attributes[:description]}."
        ENV['EC2_AMI'] = attributes[:ami]
        ENV['EC2_AMI_DEFAULT_USER'] = attributes[:ssh_user]
      end
    end

    desc "Set up AMI based on ENV[AMI_NAME] if present."
    task :from_env do
      if ENV['AMI_NAME']
        Rake::Task["ec2:ami:#{ENV['AMI_NAME']}"].invoke
      elsif ENV['EC2_AMI'].nil? || ENV['EC2_AMI_DEFAULT_USER'].nil?
        puts "Defaulting to #{DEFAULT_AMI[:description]}."
        ENV['EC2_AMI'] = DEFAULT_AMI[:ami]
        ENV['EC2_AMI_DEFAULT_USER'] = DEFAULT_AMI[:ssh_user]
      end
    end
  end
end

def with_ec2_instance
  key_id, key, id_file = ec2_auth_stuff
  instance_type, ami, ssh_user = ec2_instance_stuff
  ec2 = AWS::EC2::Base.new(:access_key_id => key_id, :secret_access_key => key)
  puts "Launching #{instance_type} instance with AMI #{ami}"
  r = ec2.run_instances(
    :image_id => ami,
    :disable_api_termination => false,
    :instance_type => instance_type,
    :key_name => File.basename(id_file, '.pem'))
  instance_id = r.instancesSet.item.first.instanceId
  instance = nil
  attempts = 0
  wait 30, "for launch of instance #{instance_id}"
  loop do
    description = ec2.describe_instances(:instance_id => instance_id)
    instance = description.reservationSet.item[0].instancesSet.item[0]
    puts "Instance is #{instance.instanceState.name}"
    break if instance.instanceState.name == "running"
    attempts += 1
    raise "Instance still not running after #{attempts} checks!" if attempts > 20
    wait 8, "for instance #{instance_id} to be running"
  end

  setup_ec2_ssh instance, id_file, ssh_user

  yield instance

rescue Exception => e
  $stderr.puts e
  raise
ensure
  if interactive?
    puts "Going to terminate instance #{instance_id}."
    binding.pry
  end
  if ec2
    puts "Terminating instance #{instance_id}."
    ec2.terminate_instances :instance_id => [instance_id]
  else
    puts "EC2 not set up. HOPEFULLY no instance was launched!"
  end
end

def ec2_auth_stuff
  key_id = ENV['AMAZON_ACCESS_KEY_ID']
  key = ENV['AMAZON_SECRET_ACCESS_KEY'] ||
    (ENV['AMAZON_SECRET_ACCESS_KEY_FILE'] && `cat #{ENV['AMAZON_SECRET_ACCESS_KEY_FILE']}`.chomp) ||
    raise("AMAZON_SECRET_ACCESS_KEY or AMAZON_SECRET_ACCESS_KEY_FILE is required")
  id_file = ENV['RAPID_FTR_IDENTITY_FILE']
  [key_id, key, id_file]
end

def ec2_instance_stuff
  instance_type = ENV['EC2_INSTANCE_TYPE'] || 'c1.medium'
  ami = ENV['EC2_AMI'] || 'ami-7000f019' # Ubuntu 10.04 LTS Lucid instance-store from http://alestic.com/
  ssh_user = ENV['EC2_AMI_DEFAULT_USER'] || 'ubuntu'
  [instance_type, ami, ssh_user]
end

def setup_ec2_ssh instance, id_file, ssh_user
  File.open('test/aws.ssh.config', 'w') do |file|
    file.write "Host ec2
      HostName #{instance.dnsName}
      User #{ssh_user}
      UserKnownHostsFile /dev/null
      StrictHostKeyChecking no
      PasswordAuthentication no
      IdentityFile #{File.expand_path(id_file)}
      IdentitiesOnly yes"
    file.puts
  end
  ENV['SSH_OPTIONS'] = "-F #{File.expand_path('test/aws.ssh.config')}"
  ENV['SSH_HOST'] = "ec2"
end

def wait seconds, reason
  puts "Waiting #{seconds} seconds #{reason}"
  sleep seconds
end

def retrying times
  tries = 0
  begin
    tries += 1
    yield
  rescue
    if tries <= times
      wait 2, "to retry"
      retry
    end
    raise
  end
end

def interactive?
  ENV['INTERACTIVE'] == 'true'
end


#################################################################
# Below here is the Rakefile from the Opscode chef-repo.
# We likely won't ever use any of it, but deleting it seems rash.
# ---------------------------------------------------------------
#
# Rakefile for Chef Server Repository
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'
require 'chef'
require 'json'

# Load constants from rake config file.
require File.join(File.dirname(__FILE__), 'config', 'rake')

# Detect the version control system and assign to $vcs. Used by the update
# task in chef_repo.rake (below). The install task calls update, so this
# is run whenever the repo is installed.
#
# Comment out these lines to skip the update.

if File.directory?(File.join(TOPDIR, ".svn"))
  $vcs = :svn
elsif File.directory?(File.join(TOPDIR, ".git"))
  $vcs = :git
end

# Load common, useful tasks from Chef.
# rake -T to see the tasks this loads.

load 'chef/tasks/chef_repo.rake'

desc "Bundle a single cookbook for distribution"
task :bundle_cookbook => [ :metadata ]
task :bundle_cookbook, :cookbook do |t, args|
  tarball_name = "#{args.cookbook}.tar.gz"
  temp_dir = File.join(Dir.tmpdir, "chef-upload-cookbooks")
  temp_cookbook_dir = File.join(temp_dir, args.cookbook)
  tarball_dir = File.join(TOPDIR, "pkgs")
  FileUtils.mkdir_p(tarball_dir)
  FileUtils.mkdir(temp_dir)
  FileUtils.mkdir(temp_cookbook_dir)

  child_folders = [ "cookbooks/#{args.cookbook}", "site-cookbooks/#{args.cookbook}" ]
  child_folders.each do |folder|
    file_path = File.join(TOPDIR, folder, ".")
    FileUtils.cp_r(file_path, temp_cookbook_dir) if File.directory?(file_path)
  end

  system("tar", "-C", temp_dir, "-cvzf", File.join(tarball_dir, tarball_name), "./#{args.cookbook}")

  FileUtils.rm_rf temp_dir
end

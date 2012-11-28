# It's expected this file will be called from a setup shell script.
# This sets up the config necessary to run chef-solo.
require 'fileutils'
require 'erb'
require 'readline'

def get env_var, prompt, valid_values = nil
  if env_value? env_var
    env_value = ENV[env_var]
    if valid_values && !valid_values.include?(env_value)
      raise "Invalid value #{env_value} for #{env_var} in environment"
    end
    puts "Using #{env_var} #{env_value}"
    env_value
  else
    attempts = 0
    value = nil
    loop do
      raise "Invalid value #{value}. Needed one of #{valid_values.inspect}" if attempts > 3
      value = Readline.readline prompt
      attempts += 1
      break if valid_values.nil? || valid_values.include?(value)
    end
    value
  end
end

def env_value? env_var
  !ENV[env_var].to_s.empty?
end

def write_file name, content
  puts "Writing #{name}..."
  puts content
  File.open(name, 'w') do |file|
    file.write content
  end
end

repo_root = File.expand_path(File.dirname(__FILE__) + '/..')
solo_config = "/etc/chef/solo.rb"
node_attribute_file = '/etc/chef/node.json'

FileUtils.mkdir_p "/etc/chef"

write_file solo_config, <<-END
# Generated from #{File.expand_path(__FILE__)} on #{Time.now}.
file_cache_path "#{repo_root}"
cookbook_path "#{repo_root}/cookbooks"
json_attribs "/etc/chef/node.json"
role_path "#{repo_root}/roles"
END

puts "

**************************************************************

  Welcome to RapidFTR setup!

**************************************************************
To generate chef-solo node configuration, we need some information.

What chef role should this server have? If it will be a primary server,
the role should be 'default'. If it will be a backup server, the role
should be 'backup'. You'll be prompted for different information later,
depending on which role you choose.
"

chef_role = get 'CHEF_ROLE', "Enter the chef role, either 'default' or 'backup':", %w[ default backup ]

puts "

**************************************************************
Next we'll deal with SSL certificates. Please provide the locations
where these files can be found. It's ok if the files aren't there yet,
just be sure to put them there before you run chef-solo.
"
if chef_role == 'backup'
  puts "Since this is a backup server, you may not have a CA-signed certificate
to use on this machine. A self-signed certificate is probably fine.
"
end

ssl_crt = File.expand_path get('SSL_CRT', "Enter the location of your certificate file (often ends in '.crt'):")
ssl_key = File.expand_path get('SSL_KEY', "Enter the location of your certificate key file (often ends in '.key'):")

puts "

**************************************************************
Now we need to know the public domain name of this server.
The application will be served from the domain name you provide.
Chef will guess this if you don't provide it. On this server it
will probably guess
    #{`hostname --fqdn`}
If that's what you want, you can just hit enter.
"
if chef_role == 'backup'
  puts "Since this is a backup server, this domain name should probably
not be known to most users and may not be very user-friendly.
"
end

fqdn = get 'FQDN', "Enter the publicly accessible domain name of this server:"

role_properties = <<-END
		"ssl_certificate": "#{ssl_crt}",
		"ssl_certificate_key": "#{ssl_key}"
		#{%(,"app_server_fqdn":"#{fqdn}") unless fqdn.empty?}
END

if chef_role == 'backup'

  puts "

**************************************************************
Next we need some information for the backup server to be able
to create an SSH connection to the main server without being
prompted for a password. You'll need a username and hostname
for the main server and the local path to the private SSH key
file whose corresponding public key will be in the user's
authorized_keys file on the main server.

If you don't already have an SSH key to use, you can generate
one on this server using the following command.
  ssh-keygen
When prompted for a passphrase, leave it blank. That will
create two files in the current user's ~/.ssh directory. The
file with no extension is the private key file. The file with
the .pub extension is the public key file.
"

  app_server_ssh_user = get 'APP_SERVER_SSH_USER', "Enter the ssh username for the connection:"
  app_server_ssh_hostname = get 'APP_SERVER_SSH_HOSTNAME', "Enter the ssh hostname for the connection:"
  backup_server_ssh_key = File.expand_path get('BACKUP_SERVER_SSH_KEY', "Enter the path to the private key file:")

  puts "

**************************************************************
Next we need an email address to receive the output from the
backup cron job, which runs every five minutes. We haven't
configured the machine to send email to external addresses, so
unless you have done so already or you intend to do so later,
you should just use the username of the account that you'll use
when you log into this server.
"

  backup_mailto = get 'BACKUP_MAILTO', "Backup notification email address:"

  role_properties << <<-END
		,"app_server_ssh_user": "#{app_server_ssh_user}",
		"app_server_ssh_hostname": "#{app_server_ssh_hostname}",
		"backup_server_ssh_key": "#{backup_server_ssh_key}",
		"backup_mailto": "#{backup_mailto}",
		"should_seed_db": false
  END
end

puts "

**************************************************************"

write_file node_attribute_file, <<-END
{
	"rapid_ftr":{
#{role_properties}
	},
	"passenger":{ "production":{ "bins_path": "/usr/local/bin" } },
	"run_list":["role[#{chef_role}]"]
}
END

puts "
**************************************************************"

if chef_role == 'backup'
  puts "Before running chef-solo, you should get the SSH keys in place and
test that the root user can connect to the main server without
being prompted for a password or to accept a new RSA fingerprint
from the main server.

If you haven't already, copy the contents of your public key
(probably #{backup_server_ssh_key}.pub) onto their own line in
the file authorized_keys in #{app_server_ssh_user}'s .ssh directory
on #{app_server_ssh_hostname}.

Now test that root can log into the main server with the following command:
  sudo ssh -i #{backup_server_ssh_key} #{app_server_ssh_user}@#{app_server_ssh_hostname} \"echo connection OK\"
"
end

puts "Chef should now be configured to run locally. If you think
any of the settings you've provided need to be changed, you can
change them directly in #{node_attribute_file}.

If all files you've referenced are in place, run the following
command to install and start RapidFTR.
  sudo chef-solo
"

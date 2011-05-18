# It's expected this file will be called from a setup shell script.
# This sets up the config necessary to run chef-solo.
require 'fileutils'
require 'erb'
require 'readline'

def get env_var, prompt
  if ENV[env_var]
    puts "Using #{env_var} #{ENV[env_var]}"
    ENV[env_var]
  else
    Readline.readline prompt
  end
end

repo_root = File.expand_path(File.dirname(__FILE__) + '/..')
solo_config = "/etc/chef/solo.rb"
node_attribute_file = '/etc/chef/node.json'

FileUtils.mkdir_p "/etc/chef"

puts "Writing #{solo_config}..."
File.open(solo_config, 'w') do |file|
  file.write <<-END
# Generated from #{File.expand_path(__FILE__)} on #{Time.now}.
file_cache_path "#{repo_root}"
cookbook_path "#{repo_root}/cookbooks"
json_attribs "/etc/chef/node.json"
role_path "#{repo_root}/roles"
  END
end

puts "

**************************************************************
To generate chef-solo configuration, we need some information.

First we'll deal with SSL certificates. Please provide the locations
where these files can be found. It's ok if the files aren't there yet,
just be sure to put them there before you run chef-solo.
"

ssl_crt = File.expand_path get('SSL_CRT', "Enter the location of your certificate file (often ends in '.crt'):")
ssl_key = File.expand_path get('SSL_KEY', "Enter the location of your certificate key file (often ends in '.key'):")

puts "

**************************************************************
Now we need to know the public domain name of your application.
Chef will guess this if you don't provide it. On this server it
will probably guess
    #{`hostname --fqdn`}
If that's what you want, you can just hit enter.
"

fqdn = get 'FQDN', "Enter the publicly accessible domain name of your server:"

puts "

**************************************************************
Writing #{node_attribute_file}..."
File.open(node_attribute_file, 'w') do |file|
  file.write <<-END
{
	"rapid_ftr":{
		"ssl_certificate": "#{ssl_crt}",
		"ssl_certificate_key": "#{ssl_key}"
		#{%(,"app_server_fqdn":"#{fqdn}") unless fqdn.empty?}
	},
	"passenger":{ "production":{ "bins_path": "/usr/bin" } },
	"run_list":["role[default]"]
}
  END
end

puts "
**************************************************************
Chef should now be configured to run locally. If your SSL certificate
files are in place, run
sudo chef-solo
to install RapidFTR."

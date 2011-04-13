# It's expected this file will be called from a setup shell script.
# This sets up the config necessary to run chef-solo.
require 'erb'
require 'readline'

repo_root = File.expand_path(File.dirname(__FILE__) + '/..')
solo_config = "/etc/chef/solo.rb"
node_attribute_file = '/etc/chef/node.json'

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

puts "**************************************************************
To generate chef-solo configuration, we need some information
about SSH certificates. Please provide the locations where these
files can be found. It's ok if the files aren't there yet, just
be sure to put them there before you run chef-solo.

If you decide you want to put them someplace else, you can edit
#{node_attribute_file} after this script is finished.
"

ssl_crt = Readline.readline("Enter the location of your certificate file (often ends in '.crt'):")
ssl_key = Readline.readline("Enter the location of your certificate key file (often ends in '.key'):")

puts "Writing #{node_attribute_file}..."
File.open(node_attribute_file, 'w') do |file|
  file.write <<-END
{
	"rapid_ftr":{
		"ssl_certificate": "#{ssl_crt}", "ssl_certificate_key": "#{ssl_key}"
	},
	"passenger":{ "production":{ "bins_path": "/usr/bin" } },
	"run_list":["role[default]"]
}
  END
end

puts "**************************************************************
Chef should now be configured to run locally. If your SSL certificate
files are in place, run
sudo chef-solo
to install RapidFTR."

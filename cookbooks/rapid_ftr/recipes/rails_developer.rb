# This recipe exists for provisioning a vagrant box
# (to jumpstart rails developers) before packaging
# it up for distribution.

include_recipe 'rapid_ftr::base'

package 'xvfb'
package 'firefox'
package 'curl'

cookbook_file "/etc/init.d/xvfb" do
  source "xvfb.init"
  owner "root"
  group "root"
  mode "0755"
end

bash 'export_DISPLAY_for_selenium' do
  code <<-END
  echo "\nexport DISPLAY=:99\n" >> /home/vagrant/.bashrc
  END
end

service 'xvfb' do
  supports :restart => true
  action [:enable, :start]
end

service 'solr' do # not needed, but we may as well have it.
  supports :restart => true
  action [:disable]
end


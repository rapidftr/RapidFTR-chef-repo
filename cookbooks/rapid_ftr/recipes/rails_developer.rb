# This recipe exists for provisioning a vagrant box
# (to jumpstart rails developers) before packaging
# it up for distribution.

include_recipe 'rapid_ftr::base'

package 'xvfb'
package 'firefox'

service 'solr' do
  supports :restart => true
  action [:disable]
end


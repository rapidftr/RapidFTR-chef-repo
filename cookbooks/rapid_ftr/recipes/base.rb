package "default-jre-headless"
package "libxml2-dev"
package "libxslt1-dev"
package "imagemagick"
gem_package "bundler"

cookbook_file "/etc/init.d/solr" do
  source "solr.init"
  owner "root"
  group "root"
  mode "0755"
end


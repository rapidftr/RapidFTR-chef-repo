package "default-jre-headless"
package "libxml2-dev"
package "libxslt1-dev"
package "imagemagick"
gem_package "bundler"

g = gem_package "rake" do
  version '0.8.7'
  action :nothing
end

g.run_action :install # Install the right version of rake before
# passenger installs a too-recent version. We have to do this
# immediately because passenger installs its gem immediately.


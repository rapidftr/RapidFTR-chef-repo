#
# Cookbook Name:: passenger
# Recipe:: install

g = gem_package "passenger/system" do
  package_name 'passenger'
  not_if "test -e /usr/local/bin/rvm-gem.sh"
  action :nothing
end

g.run_action :install # The :nothing above and this immediate install
# make sure we have passenger installed before we evaluate the daemon
# recipe, which relies on running passenger-config --root during the
# chef "compilation" phase (before convergence, which is when this
# gem would normally be installed).

gem_package "passenger/rvm" do
  package_name 'passenger'
  gem_binary "/usr/local/bin/rvm-gem.sh"
  only_if "test -e /usr/local/bin/rvm-gem.sh"
end

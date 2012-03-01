# This Gemfile is for developing and testing the chef-scripts.
# This has nothing to do with the gems that need to be installed
# to run the RapidFTR application.

source :rubygems

gem "chef"
gem "rake"
gem "vagrant", "0.9.7"
gem "amazon-ec2"
gem "pry"

group :test do
  gem "rspec-core"
  gem "rspec-expectations"
  gem "rspec-mocks" # temporarily to get TeamCity passing -- don't know why it's requiring it.
end

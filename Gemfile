# This Gemfile is for developing and testing the chef-scripts.
# This has nothing to do with the gems that need to be installed
# to run the RapidFTR application.

source :rubygems

gem "chef", "10.16.2"
gem "rake", "0.8.7"
gem "librarian", "0.0.25"

group :deploy do
  gem "vagrant", "0.9.7"
  gem "amazon-ec2"
  gem "pry"
  gem "fog"
end

group :test do
  gem "rspec-core"
  gem "rspec-expectations"
  gem "rspec-mocks"
end

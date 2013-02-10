Vagrant::Config.run do |config|
  config.vm.box = "precise32"
  config.vm.network :bridged

  config.vm.provision :chef_solo do |chef|
    chef.roles_path = "roles"
    chef.add_role "default"
  end
end

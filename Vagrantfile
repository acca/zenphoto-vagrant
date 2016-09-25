# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
configs        = YAML.load_file("#{current_dir}/vagrant_config.yaml")
vagrant_config = configs['configs'][configs['configs']['use']]

Vagrant.configure(2) do |config|

  # DigitalOcean remote deployment
  config.vm.define "zenphoto-remote" do |remote|
    remote.vm.box = "digital_ocean"

    remote.vm.provider :digital_ocean do |provider, override|
      override.ssh.private_key_path = vagrant_config['private_key_path']
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = vagrant_config['token']
      provider.image = vagrant_config['image']
      provider.region = vagrant_config['region']
      provider.size = vagrant_config['size']
    end
  end

  # VirtualBox local deployment
  config.vm.define "zenphoto-local" do |local|
    local.vm.box = "ubuntu/trusty64"

    local.vm.provider "virtualbox" do |vb|
      # apache port
      local.vm.network "forwarded_port", guest: 80, host: 8080
      vb.name = "zenphoto"
    end
  end

  # Shared configuration
  config.vm.provision "shell",
    inline: "/bin/bash /vagrant/provision.sh"
  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: ".git/"
end
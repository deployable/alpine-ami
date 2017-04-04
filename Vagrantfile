# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "./packer_virtualbox-iso_virtualbox.box"
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 22, host: 2236

  # Create a private network, which allows host-only access, fix the ip
  config.vm.network "private_network", ip: "192.168.98.60"
  #config.vm.provision "shell", run: "always", inline: "set -uex; ip ad sh dev br0 || ; ip ad sh dev br0 | grep -q 192\.168\.98\.20 || (ip ad add 192.168.98.20/24 dev br0 && ip link set dev br0 up)"


  # Create a public network, bridged network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #   # Customize the amount of memory on the VM:
    vb.memory = "512"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    set -uex
  SHELL
end

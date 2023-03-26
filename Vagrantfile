# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vbguest.auto_update = false
  config.gatling.rsync_on_startup = false
  config.vm.provider "virtualbox" do |v|
	  v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    systemctl restart sshd
  SHELL

  config.vm.define "testpr1" do |testpr1|
    testpr1.vm.network "private_network", ip: "10.10.62.10", adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "local-net"
    testpr1.vm.network "private_network", ip: "192.168.56.10", adapter: 3
    testpr1.vm.network "forwarded_port", guest: 80, host: 80
    testpr1.vm.network "forwarded_port", guest: 443, host: 443
    testpr1.vm.hostname = "test-pr1"
  end

  config.vm.define "testpr2" do |testpr2|
    testpr2.vm.network "private_network", ip: "10.10.62.11", adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "local-net"
    testpr2.vm.network "private_network", ip: "192.168.56.11", adapter: 3
    testpr2.vm.hostname = "test-pr2"
  end

  config.vm.define "testpr3" do |testpr3|
    testpr3.vm.network "private_network", ip: "10.10.62.12", adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "local-net"
    testpr3.vm.network "private_network", ip: "192.168.56.12", adapter: 3
    testpr3.vm.hostname = "test-pr3"
  end

  config.vm.define "testpr4" do |testpr4|
    testpr4.vm.network "private_network", ip: "10.10.62.13", adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "local-net"
    testpr4.vm.network "private_network", ip: "192.168.56.13", adapter: 3
    testpr4.vm.hostname = "test-pr4"

    testpr4.vm.provision "ansible" do |ansible|
      #ansible.verbose = "vvv"
      ansible.playbook = "playbook.yml"
      ansible.inventory_path = "inventories/inventory.yml"
      ansible.become = "true"
      ansible.host_key_checking = "false"
      ansible.limit = "all"
    end  
  end
  
end
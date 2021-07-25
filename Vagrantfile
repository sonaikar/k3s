# -*- mode: ruby -*-
# vi: set ft=ruby :
# vim: noai:ts=2:sw=2:et

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

UBUNTU_BOX='ubuntu/focal64'

CONTROLLER_MEM = 4096
CONTROLLER_CPUS = 4

# to find our provisioning scripts
dir = Dir.pwd
vagrant_dir = File.expand_path(File.dirname(__FILE__))

servers = {
  "k3smaster" => { :ip => "10.0.0.120", :prvip => "192.168.56.120", :bridge => "en0: Wi-Fi (AirPort)",
    :mem => CONTROLLER_MEM, :cpus => CONTROLLER_CPUS, :box => UBUNTU_BOX,
    :scripts =>  "provision/ansible-install.sh"  },
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box_check_update = false
  # enable logging in via ssh with a password
  #config.ssh.username = "vagrant"
  #config.ssh.password = "vagrant"
 
################################################################################
  servers.each do |hostname, info|

    #
    # build a vm - from the server dict
    #
    config.vm.define hostname do |cfg|  # a define per hostname
      cfg.vm.box = info[:box]
      cfg.vm.hostname = hostname

      # note the public network
#       cfg.vm.network "public_network", bridge: info[:bridge]
      cfg.vm.network "public_network", ip: info[:ip], bridge: info[:bridge]
      cfg.vm.network "private_network", ip: info[:prvip], virtualbox__intnet: true

      cfg.vm.provider "virtualbox" do |v|
        v.name = hostname
        v.memory = info[:mem]
        v.cpus = info[:cpus]
        v.customize [ "modifyvm", :id, "--hwvirtex", "on" ]
        v.customize [ "modifyvm", :id, "--uart1", "off" ]
        v.customize [ "modifyvm", :id, "--uart2", "off" ]
        v.customize [ "modifyvm", :id, "--uart3", "off" ]
        v.customize [ "modifyvm", :id, "--uart4", "off" ]
      end

      #
      # do some provisioning
      #
      ssh_prv_key = "vagrant"
      ssh_pub_key = "vagrant.pub"
      if not File.file?("#{Dir.home}/.ssh/vagrant")
        puts "No SSH key found. You will need to remedy this before pushing to the repository."
      else
        ssh_prv_key = File.read("#{Dir.home}/.ssh/vagrant")
        ssh_pub_key = File.readlines("#{Dir.home}/.ssh/vagrant.pub").first.strip

        cfg.vm.provision "shell", inline: <<-SHELL
            if grep -sq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys; then
              echo "SSH keys already provisioned."
              exit 0;
            fi
            echo "SSH key provisioning."
            mkdir -p /home/vagrant/.ssh/
            touch /home/vagrant/.ssh/authorized_keys
            echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
            echo #{ssh_pub_key} > /home/vagrant/.ssh/id_rsa.pub
            chmod 644 /home/vagrant/.ssh/id_rsa.pub
            echo "#{ssh_prv_key}" > /home/vagrant/.ssh/id_rsa
            chmod 600 /home/vagrant/.ssh/id_rsa
            chown -R vagrant:vagrant /home/vagrant
            echo "Populate hosts"
            echo "192.168.56.120 k8smaster" >> /etc/hosts
            exit 0
SHELL
      end

      #
      # per box provisioning - by hostname
      #
      provision_filename = hostname + "-provision.sh"
      cfg.vm.provision "shell", inline: "echo #{provision_filename}"
      if File.exists?(File.join(vagrant_dir,'provision',hostname + "-provision.sh")) then
          cfg.vm.provision "shell", inline: "echo +++exists+++"
          cfg.vm.provision "shell", :path => File.join( "provision", hostname + "-provision.sh" )
      else
          cfg.vm.provision "shell", inline: "echo PROVISION FILE DOES NOT EXIST!"
      end

    end # config.vm.define hostname 
  end # servers.each
################################################################################
end

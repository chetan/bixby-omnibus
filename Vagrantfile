# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  boxes = %w{
    ubuntu-10.04-i386
    ubuntu-10.04-x86_64
    ubuntu-12.04-i386
    ubuntu-12.04-x86_64
    centos-5.10-i386
    centos-5.10-x86_64
    centos-6.4-i386
    centos-6.4-x86_64
  }

  boxes.each do |box|

    url = box.gsub(/\-x86_64/, '')

    # see: https://github.com/opscode/bento
    config.vm.define(box) do |c|
      c.vm.box     = box
      c.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_#{url}_provisionerless.box"
    end

  end

  # for vagrant-vbguest plugin
  # https://github.com/dotless-de/vagrant-vbguest
  config.vbguest.iso_path = "#{ENV['HOME']}/downloads/VBoxGuestAdditions_%{version}.iso"

  # Share an additional folder to the guest VM.
  #
  # The first parameter is a path to a directory on the host machine. If the
  # path is relative, it is relative to the project root. The second parameter
  # must be an absolute path of where to share the folder within the guest
  # machine. This folder will be created (recursively, if it must) if it doesn't
  # exist.
  pkg_dir = File.join(File.expand_path(File.dirname(__FILE__)), "pkg")
  Dir.mkdir(pkg_dir) if not File.exist? pkg_dir
  config.vm.synced_folder pkg_dir, "/mnt/pkg"

  # TODO may want to fix this later
  # config.vm.share_folder "omnibus-chef", "~/omnibus-chef", File.expand_path("..", __FILE__)
  # config.vm.share_folder "omnibus-ruby", "~/omnibus-ruby", File.expand_path("../../omnibus-ruby", __FILE__)
  # config.vm.share_folder "omnibus-software", "~/omnibus-software", File.expand_path("../../omnibus-software", __FILE__)

  # Enable SSH agent forwarding for git clones
  config.ssh.forward_agent = true

  # Give enough horsepower to build PC without taking all day
  # or several hours worth of swapping  Disable support we don't need
  config.vm.provider :virtualbox do |vb|
    vb.gui = false # Boot headless
    vb.customize [
      "modifyvm", :id,
      "--memory", "1024",
      "--cpus", "1",
      "--usb", "off",
      "--usbehci", "off",
      "--audio", "none"
    ]
  end

end


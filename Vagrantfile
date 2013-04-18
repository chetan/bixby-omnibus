# -*- mode: ruby -*-
# vi: set ft=ruby :

require "bundler/setup"
# require "omnibus/vagrant/omnibus"

Vagrant::Config.run do |config|

  boxes = %w{
    ubuntu-10.04-i386
    ubuntu-10.04-x86_64
    ubuntu-12.04-i386
    ubuntu-12.04-x86_64
    centos-5.8-i386
    centos-5.8-x86_64
    centos-6.3-i386
    centos-6.3-x86_64
  }

  boxes.each do |box|

    url = box.gsub(/\\-x86_64/, '')

    # see: https://github.com/opscode/bento
    config.vm.define(box) do |c|
      c.vm.box     = box
      c.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-#{url}.box"
    end

  end

  # for vagrant-vbguest plugin
  # https://github.com/dotless-de/vagrant-vbguest
  config.vbguest.iso_path = "#{ENV['HOME']}/downloads/VBoxGuestAdditions_%{version}.iso"

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"
  pkg_dir = File.join(File.expand_path(File.dirname(__FILE__)), "pkg")
  Dir.mkdir(pkg_dir) if not File.exist? pkg_dir
  config.vm.share_folder "pkg", "~/pkg", pkg_dir

  # TODO may want to fix this later
  # config.vm.share_folder "omnibus-chef", "~/omnibus-chef", File.expand_path("..", __FILE__)
  # config.vm.share_folder "omnibus-ruby", "~/omnibus-ruby", File.expand_path("../../omnibus-ruby", __FILE__)
  # config.vm.share_folder "omnibus-software", "~/omnibus-software", File.expand_path("../../omnibus-software", __FILE__)

  # Enable SSH agent forwarding for git clones
  config.ssh.forward_agent = true

  # Give enough horsepower to build PC without taking all day
  # or several hours worth of swapping  Disable support we don't need
  config.vm.customize [
    "modifyvm", :id,
    "--memory", "1536",
    "--cpus", "2",
    "--usb", "off",
    "--usbehci", "off",
    "--audio", "none"
  ]
end


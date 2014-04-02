# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # ubuntu AMIs: https://cloud-images.ubuntu.com/locator/ec2/

  boxes = {
    # Amazon EC2
    # Ubuntu
    "ubuntu-10.04-i386"   => "ami-25a5804c",
    "ubuntu-10.04-x86_64" => "ami-2fa58046",
    "ubuntu-12.04-i386"   => "ami-c5a98cac",
    "ubuntu-12.04-x86_64" => "ami-d9a98cb0",
    "ubuntu-13.04-i386"   => "ami-931524fa",
    "ubuntu-13.04-x86_64" => "ami-951524fc",
    "ubuntu-13.10-i386"   => "ami-5725263e",
    "ubuntu-13.10-x86_64" => "ami-2f252646",

    # Amazon Linux
    "amazon-2013.9-i386"   => "ami-d7a18dbe",
    "amazon-2013.9-x86_64" => "ami-bba18dd2",
    "amazon-2014.3-i386"   => "ami-4b726522",
    "amazon-2014.3-x86_64" => "ami-2f726546",

    # Digital Ocean
    "centos-5.10-i386"    => "CentOS 5.8 x32",
    "centos-5.10-x86_64"  => "CentOS 5.8 x64",
    "centos-6.4-i386"     => "CentOS 6.4 x32",
    "centos-6.4-x86_64"   => "CentOS 6.4 x64",
  }

  boxes.each do |distro, ami|
    config.vm.define(distro) do |cfg|

      # VirtualBox
      cfg.vm.provider :virtualbox do |vb, override|
        # see: https://github.com/opscode/bento
        url = distro.gsub(/\-x86_64/, '')
        override.vm.box     = distro
        override.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_#{url}_provisionerless.box"
      end


      # AWS
      cfg.vm.provider :aws do |aws, override|

        override.ssh.username =
          if distro =~ /ubuntu/ then
            "ubuntu"
          elsif distro =~ /centos/ then
            "root"
          elsif distro =~ /amazon/ then
            "ec2-user"
          end

        aws.ami  = ami
        aws.tags = { "Name" => "bixby-build-#{distro}" }
      end


      # Digital Ocean
      cfg.vm.provider :digital_ocean do |ocean, override|
        override.vm.hostname = "bixby-build-" + distro.gsub(/x86_64/, 'x64')
        ocean.image = ami
      end
    end
  end

  config.vm.define("testing") do |cfg|
    cfg.vm.provider :virtualbox do |vb, override|
      # see: https://github.com/opscode/bento
      override.vm.box     = "ubuntu-12.04-x86_64"
      override.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
    end
  end



  # common settings

  config.vm.provision "shell", :privileged => false, :path => "scripts/bootstrap.sh"

  # for vagrant-vbguest plugin
  # https://github.com/dotless-de/vagrant-vbguest
  # config.vbguest.iso_path = "#{ENV['HOME']}/downloads/VBoxGuestAdditions_%{version}.iso"

  # shared folders
  pkg_dir = File.join(File.expand_path(File.dirname(__FILE__)), "pkg")
  Dir.mkdir(pkg_dir) if not File.exist? pkg_dir
  config.vm.synced_folder pkg_dir, "/mnt/pkg", :disabled => true
  config.vm.synced_folder ".", "/vagrant", :disabled => true

  # Enable SSH agent forwarding for git clones
  config.ssh.forward_agent = true

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

  config.vm.provider :aws do |aws, override|
    aws.region          = "us-east-1"
    aws.instance_type   = "c3.large"
    aws.security_groups = %w{ssh}

    override.vm.box     = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  config.vm.provider :digital_ocean do |ocean, override|
    ocean.region = "New York 2"
    ocean.size = "2GB"
    ocean.setup = true

    override.ssh.username = "bixby"
  end
end


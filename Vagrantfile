# -*- mode: ruby -*-
# vi: set ft=ruby :

def virtualbox(cfg, distro, ami)
  cfg.vm.provider :virtualbox do |vb, override|
    # see: https://github.com/opscode/bento
    url = distro.gsub(/\-x86_64/, '')
    override.vm.box     = distro
    override.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_#{url}_provisionerless.box"
  end
end

def aws(cfg, distro, ami)
  cfg.vm.provider :aws do |aws, override|
    override.ssh.username =
      if distro =~ /ubuntu/ then
        "ubuntu"
      elsif distro =~ /centos-7/ && ami =~ /^ami/ then
        "centos"
      elsif distro =~ /centos/ then
        "root"
      elsif distro =~ /amazon/ then
        "ec2-user"
      end

    if ami =~ /i386/ then
      aws.instance_type = "c1.medium"
    else
      aws.instance_type = "c3.large"
    end

    aws.ami  = ami
    aws.tags = { "Name" => "bixby-build-#{distro}" }
  end
end

def digitalocean(cfg, distro, ami)
  cfg.vm.provider :digital_ocean do |ocean, override|
    override.vm.hostname = "bixby-build-" + distro.gsub(/x86_64/, 'x64')
    ocean.image = ami
  end
end

Vagrant.configure("2") do |config|

  # ubuntu AMIs: https://cloud-images.ubuntu.com/locator/ec2/

  boxes = {
    # Amazon EC2
    # Ubuntu
    "ubuntu-10.04-i386"   => "ami-25a5804c", # LTS
    "ubuntu-10.04-x86_64" => "ami-2fa58046", # LTS
    "ubuntu-12.04-i386"   => "ami-c5a98cac", # LTS
    "ubuntu-12.04-x86_64" => "ami-d9a98cb0", # LTS
    "ubuntu-13.04-i386"   => "ami-931524fa",
    "ubuntu-13.04-x86_64" => "ami-951524fc",
    "ubuntu-13.10-i386"   => "ami-5725263e",
    "ubuntu-13.10-x86_64" => "ami-2f252646",
    "ubuntu-14.04-i386"   => "ami-988ad1f0", # LTS
    "ubuntu-14.04-x86_64" => "ami-808ad1e8", # LTS
    "ubuntu-14.10-i386"   => "ami-04793a6c",
    "ubuntu-14.10-x86_64" => "ami-06793a6e",

    # Amazon Linux
    "amazon-2013.09-i386"   => "ami-d7a18dbe",
    "amazon-2013.09-x86_64" => "ami-bba18dd2",
    "amazon-2014.03-i386"   => "ami-4b726522",
    "amazon-2014.03-x86_64" => "ami-2f726546",
    "amazon-2014.09-i386"   => "ami-0883c760",
    "amazon-2014.09-x86_64" => "ami-8e682ce6",

    # CentOS - on Digital Ocean & AWS
    "centos-5.10-i386"    => "centos-5-8-x32",
    "centos-5.10-x86_64"  => "centos-5-8-x64",
    "centos-6-i386"       => "ami-0e173b66",
    "centos-6-x86_64"     => "ami-06173b6e",
    "centos-7-x86_64"     => "ami-3c173b54",   # no i386 build avail
  }

  # Create boxes
  boxes.each do |distro, ami|
    config.vm.define(distro) do |cfg|

      # configure provider based on the image type
      if ami =~ /^ami/ then
        aws(cfg, distro, ami)
      else
        digitalocean(cfg, distro, ami)
      end

      # always configure vbox
      # virtualbox(cfg, distro, ami)

    end
  end


  # Create a box dedicated to testing
  config.vm.define("testing") do |cfg|
    cfg.vm.provider :virtualbox do |vb, override|
      # see: https://github.com/opscode/bento
      override.vm.box     = "ubuntu-12.04-x86_64"
      override.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"

      override.vm.synced_folder ".", "/opt/bixby-omnibus", :disabled => false
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
  config.ssh.pty = true

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
    # aws.instance_type   = "c1.medium"
    aws.security_groups = %w{ssh}

    override.vm.box     = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  config.vm.provider :digital_ocean do |ocean, override|
    ocean.region = "nyc2"
    ocean.size = "2GB"
    ocean.setup = true

    override.ssh.username = "bixby"
  end
end


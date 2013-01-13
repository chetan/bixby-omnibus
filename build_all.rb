#!/usr/bin/env ruby

require 'bundler/setup'
require 'vagrant'


class BixbyBuilder

  def self.exec(vm, cmd)
    stdout = ""
    stderr = ""
    status = vm.channel.sudo(cmd, {:error_check => false}) do |type, data|
      if type == :stdout then
        stdout += data
      else
        stderr += data
      end
    end
    return [status, stdout, stderr]
  end
end

# commands needed to do a build
cmds = <<-EOF
export PATH="$PATH:/usr/local/bin"
cd ~vagrant/omnibus-chef
gem install bundler --no-ri --no-rdoc
bundle install
rake projects:chef
EOF

# loop through each env and build
env = Vagrant::Environment.new
env.vms.each do |name, vm|

  puts name

  (status, stdout, stderr) = BixbyBuilder.exec(vm, cmds.split(/\n/).join(";"))
  puts status
  puts stdout
  puts stderr

  # break
end

#!/usr/bin/env ruby

require 'bundler/setup'
require 'vagrant'
require 'chronic_duration'

class BixbyBuilder

  def self.exec(vm, cmd)
    stdout = ""
    stderr = ""
    status = vm.channel.execute(cmd, {:error_check => false}) do |type, data|
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
cmd = '\wget -q https://raw.github.com/chetan/bixby-omnibus/master/bootstrap.sh -O - | /bin/bash'

# loop through each env and build
env = Vagrant::Environment.new
env.vms.each do |name, vm|

  puts
  puts
  puts "-----------------------------------------------------------------------"
  puts "VM: #{name}"
  puts "-----------------------------------------------------------------------"
  puts

  start = Time.new.to_i
  (status, stdout, stderr) = BixbyBuilder.exec(vm, cmd)
  elapsed = Time.new.to_i - start
  puts "status: #{status}"
  puts "elapsed: #{ChronicDuration.output(elapsed)}"
  puts
  puts "-----------------------------------------------------------------------"
  puts "stdout:"
  puts "-----------------------------------------------------------------------"
  puts stdout
  puts
  puts "-----------------------------------------------------------------------"
  puts "stderr:"
  puts "-----------------------------------------------------------------------"
  puts stderr
  puts

  # break
end

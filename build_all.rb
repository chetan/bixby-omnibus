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
cmd = '\wget -q https://raw.github.com/chetan/bixby-omnibus/master/bootstrap.sh -O - | /bin/bash'

# loop through each env and build
threads = []
env = Vagrant::Environment.new
env.vms.each do |name, vm|

  puts name

  t = Thread.new do
    (status, stdout, stderr) = BixbyBuilder.exec(vm, cmd)
    puts status
    puts stdout
    puts stderr
  end
  t[:vm] = name
  threads << t

  # break
end

puts "waiting for all threads to finish"
ThreadsWait.all_waits(threads)
puts "done!"

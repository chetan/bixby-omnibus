#!/usr/bin/env ruby

# run build on all vagrant boxes

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

only_vms = ARGV
halt = only_vms.delete("--halt")
pids = []

# commands needed to do a build
cmd = '\wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/bootstrap.sh -O - | /bin/bash'

logdir = File.expand_path(File.join(File.dirname(__FILE__), "log"))
Dir.mkdir(logdir) if not File.directory? logdir

# loop through each env and build
env = Vagrant::Environment.new
env.vms.each do |name, vm|

  if not only_vms.empty? and not only_vms.include? name.to_s then
    puts "skipping #{name}"
    next
  end

  if not vm.created?
    puts "WARNING: vm '#{name}' is not created; won't build!"
  end

  pids << fork do

    if only_vms.size > 1 then
      # redirect stdout if building more than one package
      STDOUT.reopen(File.open("#{logdir}/#{name}.log", "w+"))
    end

    puts
    puts
    puts "-----------------------------------------------------------------------"
    puts "VM: #{name}"
    puts "-----------------------------------------------------------------------"
    puts

    vm.start()

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

    # shutdown vm if we passed --halt
    if halt then
      vm.halt()
    end
  end

  # break
end

pids.each{ |pid| Process.waitpid(pid) }

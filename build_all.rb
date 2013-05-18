#!/usr/bin/env ruby

# run build on all vagrant boxes

require 'bundler/setup'
require 'chronic_duration'
require 'ostruct'
require 'mixlib/shellout'

# Temp workaround to read the list of boxes from a Vagrantfile
module Vagrant
  class Provider
    def gui=(val)
    end
    def customize(args)
    end
  end
  class VM
    class << self
      attr_accessor :boxes
    end
    def initialize
      self.class.boxes = []
    end
    def define(box)
      self.class.boxes << box
    end
    def boxes
      self.class.boxes
    end
    def provider(type, &block)
      yield Provider.new
    end
    def synced_folder(*args)
    end
  end
  class Config
    attr_reader :vm, :vbguest, :ssh
    def initialize
      @vm = VM.new
      @vbguest = OpenStruct.new
      @ssh = OpenStruct.new
    end
  end
  def self.configure(ver, &block)
    config = Config.new
    yield config
    config
  end
end

eval File.read("Vagrantfile")
boxes = Vagrant::VM.boxes

only_vms = ARGV
halt = only_vms.delete("--halt")
pids = []

# commands needed to do a build
cmd = '\wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/bootstrap.sh -O - | /bin/bash'

logdir = File.expand_path(File.join(File.dirname(__FILE__), "log"))
Dir.mkdir(logdir) if not File.directory? logdir

# loop through each env and build
boxes.each do |name|

  if not only_vms.empty? and not only_vms.include? name.to_s then
    puts "skipping #{name}"
    next
  end

  # TODO fix
  # if not vm.created?
  #   puts "WARNING: vm '#{name}' is not created; won't build!"
  # end

  pids << fork do

    if only_vms.empty? or only_vms.size > 1 then
      # redirect stdout if building more than one package
      STDOUT.reopen(File.open("#{logdir}/#{name}.log", "w+"))
    end

    puts
    puts
    puts "-----------------------------------------------------------------------"
    puts "VM: #{name}"
    puts "-----------------------------------------------------------------------"
    puts

    # TODO fix
    # vm.start()

    start = Time.new.to_i

    c = "vagrant ssh #{name} -c '#{cmd}'"
    shell = Mixlib::ShellOut.new(c)
    shell.run_command

    elapsed = Time.new.to_i - start
    puts "status: #{shell.status}"
    puts "elapsed: #{ChronicDuration.output(elapsed)}"
    puts
    puts "-----------------------------------------------------------------------"
    puts "stdout:"
    puts "-----------------------------------------------------------------------"
    puts shell.stdout
    puts
    puts "-----------------------------------------------------------------------"
    puts "stderr:"
    puts "-----------------------------------------------------------------------"
    puts shell.stderr
    puts

    # TODO fix
    # shutdown vm if we passed --halt
    # if halt then
    #   vm.halt()
    # end
  end

  # break
end

pids.each{ |pid| Process.waitpid(pid) }

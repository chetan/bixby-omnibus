
# Temp workaround to read the list of boxes from a Vagrantfile
module Vagrant

  # Read the list of boxes from the Vagrantfile
  def self.get_boxes
    eval File.read("Vagrantfile")
    return Vagrant::VM.boxes
  end

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
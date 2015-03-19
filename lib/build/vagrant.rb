
# Temp workaround to read the list of boxes from a Vagrantfile
module Vagrant

  class Binder
    def get_binding
      binding
    end
  end

  # Read the list of boxes from the Vagrantfile
  def self.get_boxes
    eval File.read("Vagrantfile"), Binder.new.get_binding, "Vagrantfile"
    return Vagrant::VM.boxes
  end

  class Provider
    attr_reader :type
    def initialize(type)
      @type = type
    end
    def method_missing(meth, *args)
    end
    def gui=(val)
    end
    def customize(args)
    end
  end

  class Machine
    attr_reader :config, :name
    def initialize(box)
      @name = box
      @config = Config.new
    end
  end

  class VM

    class << self
      def boxes
        @boxes ||= []
      end
    end

    attr_reader :providers

    def initialize
      @providers = []
    end

    def define(box)
      machine = Machine.new(box)
      self.class.boxes << machine
      yield(machine.config)
    end

    def boxes
      self.class.boxes
    end

    def provider(type, &block)
      provider = Provider.new(type)
      override = Dummy.new
      yield(provider, override)

      @providers << provider
      return provider
    end

    def method_missing(m, *a)
    end
  end

  class Config
    attr_reader :vm, :vbguest, :ssh
    def initialize
      @vm = VM.new
      @vbguest = Dummy.new
      @ssh = Dummy.new
    end
  end

  def self.configure(ver, &block)
    config = Config.new
    yield config
    config
  end

  class Dummy
    def method_missing(m, *a)
      Dummy.new
    end
  end

end

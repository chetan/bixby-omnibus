
require 'mixlib/cli'

module Bixby
  class BuildOpts

    include Mixlib::CLI

    option :halt,
      :short       => "-H",
      :long        => "--halt",
      :description => "Shutdown VM after build"

    option :boxes,
      :short       => "-b BOXES",
      :long        => "--boxes BOXES",
      :description => "Only build the given boxes (comma-separated list)"

    option :list,
      :short       => "-l",
      :long        => "--list",
      :description => "List available boxes"

    def initialize
      super
      @argv = parse_options()
    end

  end
end

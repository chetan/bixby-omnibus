
module Omnibus

  class Builder
    class DSLProxy

      private

      # Cleanup the passed in string for passing to system()
      #
      # Example:
      #
      # gem cmd_str <<-EOF
      #   install oj
      #     -v #{gem_version}
      #     -n #{install_dir}/bin
      #     --no-rdoc --no-ri
      # EOF
      #
      def cmd_str(str)
        str.strip.gsub(/[\n\t]/, " ").squeeze(" ")
      end

      # Helper for building gems
      def build_gem(name, version, bin=true)
        cmd = <<-EOF
          install #{name}
            -v #{version}
            --no-rdoc --no-ri
        EOF
        if bin then
          cmd += " -n #{@builder.install_dir}/bin"
        end
        if ENV["GEM_SERVER"] then
          cmd += " --source " + ENV["GEM_SERVER"]
        end
        gem(cmd_str(cmd))
      end

    end

  end

end

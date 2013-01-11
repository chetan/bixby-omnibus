
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
      def build_gem(name, version)
        gem cmd_str <<-EOF
          install #{name}
            -v #{version}
            -n #{@builder.install_dir}/bin
            --no-rdoc --no-ri
        EOF
      end

    end

  end

end

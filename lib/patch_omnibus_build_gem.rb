
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

    end

  end

end

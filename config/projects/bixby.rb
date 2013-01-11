
name "bixby"

install_path 	    "/opt/bixby"
build_version	    Omnibus::BuildVersion.new.git_describe # semver
build_iteration	  "1"

dependencies      %w{ preparation ruby rubygems bundler version-manifest }

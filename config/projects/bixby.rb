
name "bixby"

install_path      "/opt/bixby"
build_version     "placeholder" # will be set in bixby-agent package
build_iteration   "1"

dependencies      %w{ preparation ruby rubygems bundler bixby-agent version-manifest }

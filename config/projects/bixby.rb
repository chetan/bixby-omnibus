
name "bixby"
maintainer "Pixelcop Research, Inc."
homepage "https://bixby.io"

replaces          "bixby"
install_path      "/opt/bixby"
build_version     "placeholder" # will be set in bixby-agent package
build_iteration   1

dependencies      %w{ preparation ruby rubygems rbnacl bundler bixby-agent version-manifest }

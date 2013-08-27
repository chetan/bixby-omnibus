
name "bixby"
maintainer "Pixelcop Research, Inc."
homepage "https://bixby.io"

replaces          "bixby"
install_path      "/opt/bixby"
build_version     "placeholder" # will be set in bixby-agent package
build_iteration   1

dependencies      %w{ preparation ruby rubygems bundler bixby-agent version-manifest }

# require File.join(Omnibus::Config.project_root, "lib/patch_omnibus_http")
# require File.join(Omnibus::Config.project_root, "lib/patch_omnibus_build_gem")
# require File.join(Omnibus::Config.project_root, "lib/gem_version")

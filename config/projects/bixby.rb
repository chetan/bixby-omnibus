
name "bixby"
maintainer "Pixelcop Research, Inc."
homepage "https://bixby.io"

install_path      "/opt/bixby"
build_version     "placeholder" # will be set in bixby-agent package
build_iteration   1

dependencies      %w{ preparation ruby rubygems bundler bixby-agent version-manifest }

OMNIBUS_ROOT = File.expand_path("../..", __FILE__)
require File.join(OMNIBUS_ROOT, "lib/patch_omnibus_http")
require File.join(OMNIBUS_ROOT, "lib/patch_omnibus_build_gem")
require File.join(OMNIBUS_ROOT, "lib/gem_version")

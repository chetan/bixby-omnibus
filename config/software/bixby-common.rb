
name "bixby-common"
version Bixby.gem_version(name)

dependencies %w{ rubygems httpi systemu }

build do
  build_gem(name, version, false)
end

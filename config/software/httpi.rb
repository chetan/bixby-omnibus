
name "httpi"
version Bixby.gem_version(name)

dependencies %w{ rubygems }

build do
  build_gem(name, version, false)
end

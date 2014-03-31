
# not actually used, just here for reference

name "oj"
default_version Bixby.gem_version(name)

dependencies %w{ rubygems }

build do
  build_gem(name, version)
end

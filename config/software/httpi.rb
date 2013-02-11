
# need a custom build so we can install it from
# our private gem repo which has a custom build

name "httpi"
version Bixby.gem_version(name)

dependencies %w{ rubygems }

build do
  build_gem(name, version, false)
end

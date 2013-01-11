
name "bixby-common"
version "0.3.0"

dependencies %w{ rubygems httpi systemu }

build do
  build_gem(name, version)
end

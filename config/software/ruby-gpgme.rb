
name "ruby-gpgme"
version "2.0.5"

dependencies %w{ gpgme rubygems }

build do
  build_gem(name, version)
end

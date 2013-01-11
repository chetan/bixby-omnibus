
name "oj"
version Bixby.gem_version(name)

dependencies %w{ rubygems }

build do
  gem cmd_str <<-EOF
    install #{name}
      -v #{version}
      -n #{install_dir}/bin
      --no-rdoc --no-ri
  EOF
end

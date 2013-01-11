
name "oj"
gem_version = Bixby.gem_version(name)
version Bixby.gem_version(name)

dependencies ["rubygems"]

build do
  gem <<-EOF
    install oj
      -v #{gem_version}
      -n #{install_dir}/bin
      --no-rdoc --no-ri
  EOF
end

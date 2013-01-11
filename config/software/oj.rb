
name "oj"
gem_version = Bixby.gem_version(name)
version gem_version

dependencies ["rubygems"]

build do
  gem cmd_str <<-EOF
    install oj
      -v #{gem_version}
      -n #{install_dir}/bin
      --no-rdoc --no-ri
  EOF
end


name "bixby-auth"
default_version ENV["BIXBY_GIT_REV"] || "LAST_TAG"
always_build true

dependencies %w{ rubygems bundler }

source :git => "https://github.com/chetan/bixby-auth.git"

build do

  gem "build bixby-auth.gemspec"

  cmd = cmd_str <<-EOF
    install bixby-auth-*.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => Bixby.omnibus_env

end


name "bixby-common"
default_version ENV["BIXBY_GIT_REV"] || "LAST_TAG"
always_build true

dependencies %w{ rubygems bundler bixby-auth }

source :git => "https://github.com/chetan/bixby-common.git"

build do

  %w{multi_json httpi logging faye-websocket}.each do |g|
    gem "install #{g} -v #{Bixby.gem_version(g)} --no-rdoc --no-ri --verbose", :env => Bixby.omnibus_env
  end

  gem "build bixby-common.gemspec"

  cmd = cmd_str <<-EOF
    install bixby-common-*.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => Bixby.omnibus_env

end

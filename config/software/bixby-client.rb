
name "bixby-client"
default_version ENV["BIXBY_GIT_REV"] || "LAST_TAG"
always_build true

dependencies %w{ rubygems bundler curl bixby-common }

source :git => "https://github.com/chetan/bixby-client.git"

build do

  %w{oj curb mixlib-shellout}.each do |g|
    gem "install #{g} -v #{Bixby.gem_version(g)} --no-rdoc --no-ri", :env => Bixby.omnibus_env
  end

  gem "build bixby-client.gemspec"

  cmd = cmd_str <<-EOF
    install *.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => Bixby.omnibus_env

  block { Bixby.ruby_wrapper("bixby", install_dir) }

end

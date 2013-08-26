
name "api-auth"
version "bixby"

dependencies %w{ rubygems bundler }

source :git => "https://github.com/chetan/api_auth.git"

env = Bixby.omnibus_env

build do

  # install all runtime deps into install_dir
  bundle "install --without development test", :env => env

  # install all deps (including dev and test) into vendor for building gem
  bundle "install --deployment --without ''", :env => env
  bundle "exec rake build", :env => env

  cmd = cmd_str <<-EOF
    install pkg/*.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

end

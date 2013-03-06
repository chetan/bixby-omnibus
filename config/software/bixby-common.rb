
name "bixby-common"
version "LAST_TAG"

always_build true

dependencies %w{ rubygems bundler curl httpi }

source :git => "https://github.com/chetan/bixby-common.git"

# setup ENV for compilation
env = {
  "CFLAGS"  =>     "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LDFLAGS" => "-Wl,-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include"
}

build do

  # install all runtime deps into install_dir
  bundle "install --without development test", :env => env

  # install all deps (including dev and test) into vendor for building gem
  bundle "install --deployment --without ''", :env => env
  rake "build", :env => env

  cmd = cmd_str <<-EOF
    install pkg/bixby-common-*.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

end

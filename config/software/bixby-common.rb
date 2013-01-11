
name "bixby-common"
version "master"

source :git => "https://github.com/chetan/bixby-common.git"

dependencies %w{ rubygems }

# setup ENV for compilation
env = {
  "CFLAGS"  =>     "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LDFLAGS" => "-Wl,-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include"
}

build do

  bundle "install --deployment", :env => env
  rake "build", :env => env

  cmd = cmd_str <<-EOF
    install pkg/bixby-common-*.gem
    -n #{install_dir}/bin
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

end

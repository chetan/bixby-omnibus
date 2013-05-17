
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

  %w{multi_json logging}.each do |g|
    gem "install #{g} -v #{Bixby.gem_version(g)} --no-rdoc --no-ri --verbose", :env => env
  end

  gem "build bixby-common.gemspec"

  cmd = cmd_str <<-EOF
    install bixby-common-*.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

end

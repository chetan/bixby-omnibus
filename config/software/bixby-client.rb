
name "bixby-client"
version "LAST_TAG"
always_build true

dependencies %w{ rubygems bundler bixby-common api-auth httpi }

source :git => "https://github.com/chetan/bixby-client.git"

# setup ENV for compilation
env = {
  "CFLAGS"  =>     "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LDFLAGS" => "-Wl,-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include"
}

build do

  %w{multi_json oj curb mixlib-shellout}.each do |g|
    gem "install #{g} -v #{Bixby.gem_version(g)}", :env => env
  end

  gem "build bixby-client.gemspec"

  cmd = cmd_str <<-EOF
    install *.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

end

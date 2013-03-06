
name "httpi"
version "chunked_responses"

dependencies %w{ rubygems bundler }

source :git => "https://github.com/chetan/httpi.git"

# setup ENV for compilation
env = {
  "CFLAGS"  =>     "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LDFLAGS" => "-Wl,-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include"
}

build do

  gem "build httpi.gemspec"

  cmd = cmd_str <<-EOF
    install *.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

end

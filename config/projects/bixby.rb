
name "bixby"
maintainer "Pixelcop Research, Inc."
homepage "https://bixby.io"

replaces          "bixby"
install_path      "/opt/bixby"
build_version     "placeholder" # will be set in bixby-agent package
build_iteration   1

override :ruby, :version => "2.2.0"

dependencies      %w{ preparation ruby rubygems libffi rbnacl bundler bixby-agent version-manifest }

if `cat /etc/issue` =~ /Amazon Linux/ then
  # $ rpm -qa glibc
  # glibc-2.12-1.107.43.amzn1.x86_64
  `rpm -qa glibc` =~ /^glibc-(\d+\.\d+)/
  glibc_ver = $1
  runtime_dependency "glibc = #{glibc_ver}"
end

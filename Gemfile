source "https://rubygems.org"
source "http://192.168.80.98:7000/"

gem "omnibus", :git => "https://github.com/chetan/omnibus-ruby.git", :branch => "bixby"
gem "omnibus-software", :git => "https://github.com/chetan/omnibus-software.git", :branch => "bixby"

group :development do
  gem "vagrant-wrapper"
  gem "mixlib-shellout"
  gem "ffi", "~> 1.3" # explicit definition to fix bundler bug
  gem "pry"
  gem "chronic_duration"
end

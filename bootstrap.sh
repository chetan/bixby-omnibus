#!/usr/bin/env bash

USER=chetan
GROUP=chetan

# for wget/curl/yum proxy caching
export http_proxy="http://192.168.80.98:8000"

function is_centos() {
  issue=`cat /etc/issue`
  if [[ $issue == CentOS* ]]; then
    return 0
  else
    return 1
  fi
}

function is_ubuntu() {
  issue=`cat /etc/issue`
  if [[ $issue == Ubuntu* ]]; then
    return 0
  else
    return 1
  fi
}

# need build tools
if [[ -z `which gcc` ]]; then
  echo "installing build tools (via sudo)"
  if [[ is_ubuntu ]]; then
    echo "Acquire { Retries \"0\"; HTTP { Proxy \"$http_proxy\"; }; };" > 30apt-proxy
    sudo mv 30apt-proxy /etc/apt/apt.conf.d
    sudo apt-get -qqy install build-essential libssl-dev zlib1g-dev libreadline-dev libcurl4-openssl-dev

    # ruby
    sudo apt-get -qqy install ruby rubygems libopenssl-ruby ruby-dev
    sudo -E gem install --no-ri --no-rdoc rubygems-update
    sudo ruby /var/lib/gems/1.8/gems/rubygems-update-*/setup.rb
    sudo -E gem install --no-ri --no-rdoc bundler

  elif [[ is_centos ]]; then
    sudo -E yum -qy groupinstall "Development Tools"
    sudo -E yum -qy install openssl-devel zlib-devel readline-devel curl-devel
  fi
fi

# install git
if [[ -z `which git` ]]; then
  echo "installing git (via sudo)"
  if [[ is_ubuntu ]]; then
    sudo apt-get -qqy install git-core
  elif [[ is_centos ]]; then
    sudo yum -qy install git
  fi
fi

# setup base dir
echo "creating /opt/bixby (via sudo)"
sudo mkdir -p /var/cache/omnibus
sudo chown $USER:$GROUP /var/cache/omnibus
sudo rm -rf /opt/bixby
sudo mkdir /opt/bixby
sudo chown $USER:$GROUP /opt/bixby

# omnibus!
cd
git clone https://github.com/chetan/bixby-omnibus.git
cd bixby-omnibus
bundle install

export GEM_SERVER="http://192.168.80.98:7000/"
./build.sh

# cleanup
unset http_proxy
unset GEM_SERVER

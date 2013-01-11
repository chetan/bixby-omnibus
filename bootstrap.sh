#!/usr/bin/env bash

BUILD_LOG="/tmp/bixby-omnibus.log"

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

function unknown_distro() {
    echo
    echo
    echo "ERROR: only Ubuntu and CentOS are current supported!"
    echo
    exit 1
}

echo "BUILD START - `date`" > $BUILD_LOG
echo "##########################################" > $BUILD_LOG
echo > $BUILD_LOG

# need build tools
if [[ -z `which gcc` ]]; then
  echo "installing build tools (via sudo)"
  if is_ubuntu; then
    echo "Acquire { Retries \"0\"; HTTP { Proxy \"$http_proxy\"; }; };" > 30apt-proxy
    sudo mv 30apt-proxy /etc/apt/apt.conf.d
    sudo apt-get -qqy install build-essential libssl-dev zlib1g-dev libreadline-dev libcurl4-openssl-dev >> $BUILD_LOG

    # ruby
    sudo apt-get -qqy install ruby rubygems libopenssl-ruby ruby-dev >> $BUILD_LOG
    sudo -E gem install --no-ri --no-rdoc rubygems-update >> $BUILD_LOG
    sudo ruby /var/lib/gems/1.8/gems/rubygems-update-*/setup.rb >> $BUILD_LOG
    sudo -E gem install --no-ri --no-rdoc bundler >> $BUILD_LOG

  elif is_centos; then
    sudo -E yum -qy groupinstall "Development Tools" >> $BUILD_LOG
    sudo -E yum -qy install openssl-devel zlib-devel readline-devel curl-devel >> $BUILD_LOG

  else
    unknown_distro
  fi
fi

# install git
if [[ -z `which git` ]]; then
  echo "installing git (via sudo)"
  if is_ubuntu; then
    sudo apt-get -qqy install git-core >> $BUILD_LOG
  elif is_centos; then
    sudo yum -qy install git >> $BUILD_LOG
  else
    unknown_distro
  fi
fi

# setup base dir
echo "creating /opt/bixby (via sudo)"
sudo mkdir -p /var/cache/omnibus
sudo chown $USER /var/cache/omnibus
sudo rm -rf /opt/bixby
sudo mkdir /opt/bixby
sudo chown $USER /opt/bixby

# omnibus!
cd
git clone https://github.com/chetan/bixby-omnibus.git
cd bixby-omnibus
bundle install >> $BUILD_LOG

export GEM_SERVER="http://192.168.80.98:7000/"
./build.sh

# cleanup
unset http_proxy
unset GEM_SERVER

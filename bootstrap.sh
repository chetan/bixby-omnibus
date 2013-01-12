#!/usr/bin/env bash

BUILD_LOG="/tmp/bixby-omnibus.log"

# for wget/curl/yum proxy caching
export http_proxy="http://192.168.80.98:8000"

issue=`cat /etc/issue`
function is_centos() {
  [[ $issue =~ "^CentOS" ]]
}

function is_ubuntu() {
  [[ $issue == Ubuntu* ]]
}

function unknown_distro() {
    echo
    echo
    echo "ERROR: only Ubuntu and CentOS are current supported!"
    echo
    exit 1
}

function is_64() {
  [[ `uname -p` == "x86_64" ]]
}

function install_rpmforge() {
  if [[ $issue =~ 'release 5' ]]; then
    if is_64; then
      wget -q http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
    else
      wget -q http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
    fi
  elif [[ $issue =~ 'release 6' ]]; then
    if is_64; then
      wget -q http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
    else
      wget -q http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
    fi
  else
    unknown_distro
  fi
  rpm -Uvh rpmforge*.rpm && rm -f rpmforge*.rpm
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
    # sudo apt-get -qqy install ruby rubygems libopenssl-ruby ruby-dev >> $BUILD_LOG

  elif is_centos; then
    install_rpmforge
    sudo -E yum -qy groupinstall "Development Tools" >> $BUILD_LOG
    sudo -E yum -qy install openssl-devel zlib-devel readline-devel curl-devel >> $BUILD_LOG
    # sudo -E yum -qy install ruby ruby-devel rubygems >> $BUILD_LOG
    unalias cp rm mv

  else
    unknown_distro
  fi

  # update rubygems, install bundler
  # sudo -E gem install --no-ri --no-rdoc rubygems-update >> $BUILD_LOG
  # sudo ruby /var/lib/gems/1.8/gems/rubygems-update-*/setup.rb >> $BUILD_LOG
  # sudo -E gem install --no-ri --no-rdoc bundler >> $BUILD_LOG
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

# install ruby via rvm
# \curl -L https://raw.github.com/chetan/rvm/noprompt/binscripts/rvm-installer | bash -s stable --ruby

# install ruby
git clone git://github.com/sstephenson/ruby-build.git
cd ruby-build
sudo ./install.sh
cd ..
sudo -E ruby-build 1.9.3-p362 /usr/local
sudo -E gem install --no-ri --no-rdoc bundler >> $BUILD_LOG



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

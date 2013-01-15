#!/bin/bash -e

# oneliner usage:
# \wget -q https://raw.github.com/chetan/bixby-omnibus/master/bootstrap.sh -O - | /bin/bash
#
# or with curl:
# \curl -Ls https://raw.github.com/chetan/bixby-omnibus/master/bootstrap.sh | /bin/bash
#
# (can be run as a normal user OR root)


# CONFIG
export http_proxy="http://192.168.80.98:8000"
export GEM_SERVER="http://192.168.80.98:7000/"



# END CONFIG -------------------------------------------------------------------

# set -e

BUILD_LOG="/tmp/bixby-omnibus.log"

issue=`cat /etc/issue`
function is_centos() {
  [[ $issue =~ ^CentOS ]]
}

function is_ubuntu() {
  [[ $issue =~ ^Ubuntu ]]
}

function unknown_distro() {
    echo
    echo
    echo "ERROR: only Ubuntu and CentOS are currently supported!"
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

# only use sudo when necessary
# i.e., centos will generally be root already
function as_root() {
  if [[ `whoami` == root ]]; then
    $*
  else
    sudo -E $*
  fi
}

echo "BUILD START - `date`" > $BUILD_LOG
echo "##########################################" > $BUILD_LOG
echo > $BUILD_LOG

# basics (sudo & wget)
if is_centos && [[ -z `which sudo 2>/dev/null` ]]; then
  yum -q -y install sudo >> $BUILD_LOG
fi
if [[ -z `which wget 2>/dev/null` ]]; then
  echo "installing wget (via sudo)"
  is_centos && as_root yum -q -y install wget >> $BUILD_LOG
  is_ubuntu && as_root apt-get -qqy install wget >> $BUILD_LOG
fi

# need build tools
if [[ -z `which gcc 2>/dev/null` ]]; then
  echo "installing build tools (via sudo)"
  if is_ubuntu; then
    echo "Acquire { Retries \"0\"; HTTP { Proxy \"$http_proxy\"; }; };" > 30apt-proxy
    as_root mv 30apt-proxy /etc/apt/apt.conf.d
    as_root apt-get -qqy install build-essential libssl-dev zlib1g-dev libreadline-dev libcurl4-openssl-dev >> $BUILD_LOG

  elif is_centos; then
    install_rpmforge
    as_root yum -q -y groupinstall "Development tools" >> $BUILD_LOG
    as_root yum -q -y install openssl-devel zlib-devel readline-devel >> $BUILD_LOG

  else
    unknown_distro
  fi
fi

# install git
if [[ -z `which git 2>/dev/null` ]]; then
  echo "installing git (via sudo)"
  if is_ubuntu; then
    as_root apt-get -qqy install git-core >> $BUILD_LOG
  elif is_centos; then
    as_root yum -q -y install git >> $BUILD_LOG
  else
    unknown_distro
  fi
fi

# install ruby
if [[ -z `which ruby 2>/dev/null` ]]; then
  cd
  if [[ ! -d ruby-build ]]; then
    git clone git://github.com/sstephenson/ruby-build.git
  fi
  cd ruby-build
  git pull -q
  as_root ./install.sh
  cd ..
  as_root ruby-build 1.9.3-p362 /usr/local
  as_root gem install --no-ri --no-rdoc bundler >> $BUILD_LOG
fi

# setup base dir
echo "creating /opt/bixby (via sudo)"
as_root mkdir -p /var/cache/omnibus
as_root chown $USER /var/cache/omnibus
as_root rm -rf /opt/bixby
as_root mkdir /opt/bixby
as_root chown $USER /opt/bixby

# omnibus!
cd
if [[ ! -d bixby-omnibus ]]; then
  git clone https://github.com/chetan/bixby-omnibus.git
fi
cd bixby-omnibus
git reset --hard
git pull -q
bundle install >> $BUILD_LOG
if [[ $? -ne 0 ]]; then
  echo "bundle install failed for bixby-omnibus"
  echo "details in $BUILD_LOG"
  exit 1
fi

./build.sh

# cleanup
unset http_proxy
unset GEM_SERVER

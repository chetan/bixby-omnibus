#!/bin/bash -e

# kickoff the build on a target distro (e.g. within a VM)

# oneliner usage:
# \wget -q https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh -O - | /bin/bash
#
# or with curl:
# \curl -Ls https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh | /bin/bash
#
# (can be run as a normal user with sudo OR root)


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
  if [[ `yum repolist | grep rpmforge` ]]; then
    # already installed
    return 0
  fi

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
  as_root rpm -Uvh rpmforge*.rpm && rm -f rpmforge*.rpm
}

# only use sudo when necessary
# i.e., centos will generally be root already
#
# vagrant will always use the user 'vagrant'
function as_root() {
  if [[ `whoami` == root ]]; then
    $*
  else
    sudo env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" $*
  fi
}

echo "BUILD START - `date`" > $BUILD_LOG
echo "##########################################" > $BUILD_LOG
echo > $BUILD_LOG

# basics (sudo & wget)
# fix sudo PATH first
if [[ ! `sudo env | egrep ^PATH | egrep '[:=]?/usr/local/bin'` ]]; then
  sudo su -c 'echo export PATH="/usr/local/bin:\$PATH" >> /root/.bashrc'
fi

# make sure apt/yum are fresh
is_ubuntu && as_root apt-get -qqy update > /dev/null
is_centos && as_root yum -q -y check-update >> /dev/null

if is_centos && [[ -z `which sudo 2>/dev/null` ]]; then
  yum -q -y install sudo >> $BUILD_LOG
fi
if [[ -z `which wget 2>/dev/null` ]]; then
  echo "installing wget (via sudo)"
  is_centos && as_root yum -q -y install wget >> $BUILD_LOG
  is_ubuntu && as_root apt-get -qqy install wget >> $BUILD_LOG
fi

# setup http proxy for apt
if is_ubuntu && [[ ! -f /etc/apt/apt.conf.d/30apt-proxy ]]; then
  echo "Acquire { Retries \"0\"; HTTP { Proxy \"$http_proxy\"; }; };" > /tmp/30apt-proxy
  as_root mv /tmp/30apt-proxy /etc/apt/apt.conf.d
fi

# add rpmforge to centos
is_centos && install_rpmforge

# pre-emptively fix grub
# grub sometimes barfs when a new vm is created so fix it up
# may have an error when grub is upgraded on e.g. ubuntu 12
as_root grub-install /dev/sda > /dev/null

# update system
is_ubuntu && as_root apt-get -qqy upgrade >> $BUILD_LOG
is_centos && as_root yum -q -y upgrade >> $BUILD_LOG

# need build tools
if [[ -z `which gcc 2>/dev/null` ]]; then
  echo "installing build tools (via sudo)"
  if is_ubuntu; then
    as_root apt-get -qqy install build-essential >> $BUILD_LOG

  elif is_centos; then
    as_root yum -q -y groupinstall "Development tools" >> $BUILD_LOG

  else
    unknown_distro
  fi
fi

# install other deps
if is_ubuntu; then
  as_root apt-get -qqy install libssl-dev zlib1g-dev libreadline-dev libcurl4-openssl-dev  >> $BUILD_LOG

elif is_centos; then
  as_root yum -q -y install openssl-devel zlib-devel readline-devel >> $BUILD_LOG
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

# install ruby if correct version is not present
if [[ -z `which ruby 2>/dev/null` || ! `ruby -v | grep 1.9.3p362` ]]; then
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
as_root chown -R $USER /var/cache/omnibus
as_root rm -rf /opt/bixby
as_root mkdir /opt/bixby
as_root chown -R $USER /opt/bixby

# omnibus!
cd
if [[ ! -d bixby-omnibus ]]; then
  git clone https://github.com/chetan/bixby-omnibus.git
  cd bixby-omnibus
else
  cd bixby-omnibus
  git reset --hard
  git pull -q
fi
bundle install >> $BUILD_LOG
if [[ $? -ne 0 ]]; then
  echo "bundle install failed for bixby-omnibus"
  echo "details in $BUILD_LOG"
  exit 1
fi

scripts/build.sh

# cleanup
unset http_proxy
unset GEM_SERVER
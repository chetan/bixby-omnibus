#!/bin/bash

# kickoff the build on a target distro (e.g. within a VM)

# oneliner usage:
# \wget -q https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh -O - | /bin/bash
#
# or with curl:
# \curl -Ls https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh | /bin/bash
#
# (can be run as a normal user with sudo OR root)


# CONFIG
# export http_proxy="http://192.168.80.98:8000"
# export GEM_SERVER="http://192.168.80.98:7000/"



# END CONFIG -------------------------------------------------------------------

# set -e
set -x

issue=`cat /etc/issue`
is_centos() {
  [[ $issue =~ ^CentOS ]]
}

is_amazon() {
  a='^Amazon Linux AMI'
  [[ $issue =~ $a ]]
}

is_ubuntu() {
  [[ $issue =~ ^Ubuntu ]]
}

unknown_distro() {
    echo
    echo
    echo "ERROR: only Ubuntu, CentOS, and Amazon Linux are currently supported!"
    echo
    exit 1
}

is_64() {
  [[ `uname -p` == "x86_64" ]]
}

install_rpmforge() {
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
as_root() {
  if [[ `whoami` == root ]]; then
    "$@"
  else
    sudo env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" "$@"
  fi
}

# basics (sudo & wget)
# fix sudo PATH first
if [[ ! `sudo env | egrep ^PATH | egrep '[:=]?/usr/local/bin'` ]]; then
  sudo su -c 'echo export PATH="/usr/local/bin:\$PATH" >> /root/.bashrc'
fi

# make sure apt/yum are fresh
is_ubuntu && as_root apt-get -qqy update > /dev/null
(is_centos || is_amazon) && as_root yum -q -y check-update > /dev/null

if is_centos && [[ -z `which sudo 2>/dev/null` ]]; then
  yum -q -y install sudo
fi

# Force APT to use our http_proxy
# Note that Yum on CentOS will pickup and use http_proxy from the ENV
# if is_ubuntu && [[ ! -z "$http_proxy" ]] && [[ ! -f /etc/apt/apt.conf.d/30apt-proxy ]]; then
#   echo "Acquire { Retries \"0\"; HTTP { Proxy \"$http_proxy\"; }; };" > /tmp/30apt-proxy
#   as_root mv /tmp/30apt-proxy /etc/apt/apt.conf.d
# fi

if [[ -z `which wget 2>/dev/null` ]]; then
  echo "installing wget (via sudo)"
  (is_centos || is_amazon) && as_root yum -q -y install wget
  is_ubuntu && as_root apt-get -qqy install wget
fi

# add rpmforge to centos
is_centos && install_rpmforge

# pre-emptively fix grub
# grub sometimes barfs when a new vm is created so fix it up
# may have an error when grub is upgraded on e.g. ubuntu 12
if [[ -n `which grub-install 2>/dev/null` ]]; then
  as_root grub-install /dev/sda > /dev/null
fi

# update system
if is_ubuntu; then
  # had issues with simply using -y due to grub config popping up anyway
  # http://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
  as_root DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
  as_root apt-get -qqy autoremove
  as_root apt-get -qqy autoclean

elif is_centos; then
  # we don't upgrade amazon here to avoid upgrading to a newer release
  as_root yum -q -y upgrade
fi


# need build tools
if [[ -z `which gcc 2>/dev/null` ]]; then
  echo "installing build tools (via sudo)"
  if is_ubuntu; then
    as_root apt-get -qqy install build-essential

  elif is_centos || is_amazon; then
    as_root yum -q -y groupinstall "Development Tools"

  else
    unknown_distro
  fi
fi

# install other deps
if is_ubuntu; then
  as_root apt-get -qqy install libssl-dev zlib1g-dev libreadline-dev libcurl4-openssl-dev libxslt1-dev libxml2-dev ntpdate curl screen
  as_root ntpdate ntp.ubuntu.com

elif is_centos || is_amazon; then
  as_root yum -q -y install openssl-devel zlib-devel readline-devel libxslt-devel libxml2-devel ntp screen
  as_root /usr/sbin/ntpdate ntp.ubuntu.com

fi

# install git
if [[ -z `which git 2>/dev/null` ]]; then
  echo "installing git (via sudo)"
  if is_ubuntu; then
    as_root apt-get -qqy install git-core
  elif is_centos || is_amazon; then
    as_root yum -q -y install git
  else
    unknown_distro
  fi
fi


# install ruby
wget -O ruby-install-0.4.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.1.tar.gz
tar -xzf ruby-install-0.4.1.tar.gz
cd ruby-install-0.4.1/
sudo make install
cd ..
sudo rm -rf ruby-install-*
sudo /usr/local/bin/ruby-install -i /usr/local ruby 1.9.3-p545
sudo /usr/local/bin/gem install --no-ri --no-rdoc bundler -v 1.5.3

# setup base dirs
echo "creating /opt/bixby (via sudo)"
as_root mkdir -p /var/cache/omnibus
as_root chown -R $USER /var/cache/omnibus
as_root rm -rf /opt/bixby
as_root mkdir /opt/bixby
as_root chown -R $USER /opt/bixby

# checkout omnibus
cd
git clone https://github.com/chetan/bixby-omnibus.git
cd bixby-omnibus
bundle install

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
# export http_proxy="http://192.168.80.98:8000"
# export GEM_SERVER="http://192.168.80.98:7000/"



# END CONFIG -------------------------------------------------------------------

# set -e
set -x

issue=`cat /etc/issue`
is_centos() {
  [[ $issue =~ ^CentOS ]]
}

is_ubuntu() {
  [[ $issue =~ ^Ubuntu ]]
}

unknown_distro() {
    echo
    echo
    echo "ERROR: only Ubuntu and CentOS are currently supported!"
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

echo -e "############################################\nBUILD STARTED - `date`\n############################################"
echo

# basics (sudo & wget)
# fix sudo PATH first
if [[ ! `sudo env | egrep ^PATH | egrep '[:=]?/usr/local/bin'` ]]; then
  sudo su -c 'echo export PATH="/usr/local/bin:\$PATH" >> /root/.bashrc'
fi

# make sure apt/yum are fresh
is_ubuntu && as_root apt-get -qqy update > /dev/null
is_centos && as_root yum -q -y check-update >> /dev/null

if is_centos && [[ -z `which sudo 2>/dev/null` ]]; then
  yum -q -y install sudo
fi

# Force APT to use our http_proxy
# Note that Yum on CentOS will pickup and use http_proxy from the ENV
if is_ubuntu && [[ ! -z "$http_proxy" ]] && [[ ! -f /etc/apt/apt.conf.d/30apt-proxy ]]; then
  echo "Acquire { Retries \"0\"; HTTP { Proxy \"$http_proxy\"; }; };" > /tmp/30apt-proxy
  as_root mv /tmp/30apt-proxy /etc/apt/apt.conf.d
fi

if [[ -z `which wget 2>/dev/null` ]]; then
  echo "installing wget (via sudo)"
  is_centos && as_root yum -q -y install wget
  is_ubuntu && as_root apt-get -qqy install wget
fi

# add rpmforge to centos
is_centos && install_rpmforge

# pre-emptively fix grub
# grub sometimes barfs when a new vm is created so fix it up
# may have an error when grub is upgraded on e.g. ubuntu 12
as_root grub-install /dev/sda > /dev/null

# update system
if is_ubuntu; then
  # had issues with simply using -y due to grub config popping up anyway
  # http://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
  as_root DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
  as_root apt-get -qqy autoremove
  as_root apt-get -qqy autoclean

elif is_centos; then
  as_root yum -q -y upgrade
fi


# need build tools
if [[ -z `which gcc 2>/dev/null` ]]; then
  echo "installing build tools (via sudo)"
  if is_ubuntu; then
    as_root apt-get -qqy install build-essential

  elif is_centos; then
    as_root yum -q -y groupinstall "Development tools"

  else
    unknown_distro
  fi
fi

# install other deps
if is_ubuntu; then
  as_root apt-get -qqy install libssl-dev zlib1g-dev libreadline-dev libcurl4-openssl-dev libxslt1-dev libxml2-dev ntpdate
  as_root ntpdate ntp.ubuntu.com

elif is_centos; then
  as_root yum -q -y install openssl-devel zlib-devel readline-devel libxslt-devel libxml2-devel ntp
  as_root /sbin/ntpdate ntp.ubuntu.com

fi

# install git
if [[ -z `which git 2>/dev/null` ]]; then
  echo "installing git (via sudo)"
  if is_ubuntu; then
    as_root apt-get -qqy install git-core
  elif is_centos; then
    as_root yum -q -y install git
  else
    unknown_distro
  fi
fi

# install ruby if correct version is not present
if [[ -z `which ruby 2>/dev/null` || ! `ruby -v | grep 1.9.3` ]]; then
  cd
  \curl -sSL https://get.rvm.io | sudo PATH="$PATH:/usr/sbin" bash -s stable
  sudo /usr/sbin/usermod -a -G rvm bixby
  newgrp rvm
  /usr/local/rvm/bin/rvm install 1.9.3-p484
  /usr/local/rvm/bin/rvm use 1.9.3-p484 --default
fi

# upgrade bundler to at least 1.3.0
ruby -rbundler -e 'exit 1 if Gem::Version.new(Bundler::VERSION) < Gem::Version.new("1.3.0")'
if [[ $? -ne 0 ]]; then
  as_root gem uninstall -Ixa bundler
  as_root gem install --no-ri --no-rdoc bundler
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
bundle install
if [[ $? -ne 0 ]]; then
  echo "bundle install failed for bixby-omnibus"
  echo "details in $HOME/bixby-omnibus.log"
  exit 1
fi

scripts/build.sh

# cleanup
unset http_proxy
unset GEM_SERVER

echo "Packages:\n---------"
cd
ls -l bixby-omnibus/pkg/

echo
echo
echo -e "#############################################\nBUILD FINISHED - `date`\n#############################################"

#!/usr/bin/env bash

# script for uploading package files to s3
# run on a guest system (build server)
# called from bin/upload_packages helper

PKGDIR="$HOME/bixby-omnibus/pkg/"

cd $PKGDIR

# make sure we have some packages
if [[ `ls | wc -l` == "0" ]]; then
  echo "no packages to upload on $(cat /etc/issue)"
  exit 1
fi

# remove timestamp from version
#
# bixby_0.2.0+20131122223752-1.ubuntu.12.04_amd64.deb
# becomes
# bixby_0.2.0-1.ubuntu.12.04_amd64.deb

beta=""
if [[ "$BETA" != "" ]]; then
  beta=".$BETA"
fi

current=$(ls *.deb *.rpm 2>/dev/null | head -n 1 | perl -ne '/bixby.(.*?-1)/; print $1')
ver=$(echo $current | perl -ne '/^(.*?)\+.*$/; print $1')

if [[ "$ver" != "" ]]; then
  echo "* renaming packages"
  for f in `ls bixby*.deb bixby*.rpm bixby*.metadata.json 2>/dev/null`; do
    nf=$(echo $f | sed -e "s/$ver[+0-9]*/$ver/")
    mv $f $nf
  done
fi


# UPLOAD
if [[ -z `which s3cp 2>/dev/null` ]]; then
  gem install s3cp --no-ri --no-rdoc
fi


# CentOS release 5.10
# Ubuntu 13.04
issue=`cat /etc/issue`
dir=""
a='^Amazon Linux AMI'
if [[ $issue =~ ^CentOS ]]; then
  dir="centos"
  ver=$(echo $issue | head -n 1 | perl -ne '/([0-9]+)\.[0-9]+/; print $1')

elif [[ $issue =~ $a ]]; then
  dir="amazon"
  ver=$(echo $issue | head -n 1 | perl -ne '/([0-9]+\.[0-9]+)/; print $1')
  # remove 'el2014' from filenames
  # bixby-0.2.4-1.el2014.x86_64.rpm -> bixby-0.2.4-1.x86_64.rpm
  for f in `ls bixby*.rpm bixby*.metadata.json 2>/dev/null`; do
    nf=$(echo $f | sed -e "s/el[0-9]*\.//")
    mv $f $nf
  done

elif [[ $issue =~ ^Ubuntu ]]; then
  dir="ubuntu"
  ver=$(echo $issue | head -n 1 | perl -ne '/([0-9]+\.[0-9]+)/; print $1')
fi
dir="$dir/$ver"


echo "* uploading packages"
cd $PKGDIR
s3cp --max-attempts 3 * s3://s3.bixby.io/agent/$dir/ && echo "* done"

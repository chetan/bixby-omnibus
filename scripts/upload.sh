#!/usr/bin/env bash

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

current=$(ls *.deb *.rpm 2>/dev/null | head -n 1 | perl -ne '/bixby.(.*?-1)/; print $1')
ver=$(echo $current | perl -ne '/^(.*?)\+.*$/; print $1')

if [[ "$ver" != "" ]]; then
  echo "* renaming packages"
  for f in `ls bixby*.deb bixby*.rpm bixby*.metadata.json`; do
    nf=$(echo $f | sed -e "s/$ver[+0-9]*/$ver/")
    mv $f $nf
  done
fi


# UPLOAD
cd $HOME
if [[ ! -d boto ]]; then
  git clone -q https://github.com/boto/boto.git
  cd $HOME/boto/
  git checkout -b 2.9.9 2.9.9
fi

echo "* uploading packages"
cd $HOME/boto
bin/s3put -p $PKGDIR -b s3.bixby.io -k agent/ $PKGDIR/*

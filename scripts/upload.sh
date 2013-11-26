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
if [[ -z `which s3cp 2>/dev/null` ]]; then
  sudo gem install s3cp --no-ri --no-rdoc
fi

echo "* uploading packages"
cd $PKGDIR
s3cp --max-attempts 3 * s3://s3.bixby.io/agent/ && echo "* done"

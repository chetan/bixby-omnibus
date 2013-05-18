#!/usr/bin/env bash

# run's the actual build and creates a package via fpm.
#
# this should be run inside a vm on the target platform.
# normally called from bootstrap.sh

export ROOT=$(dirname $(readlink -f $0))
cd $ROOT

# need bixby-agent checked out for installing it's gem deps
mkdir -p tmp
cd tmp
if [[ -d bixby-agent ]]; then
  cd bixby-agent
  git pull -q
else
  git clone https://github.com/chetan/bixby-agent.git
fi
cd $ROOT

rm -rf pkg /var/cache/omnibus/pkg
rake clean projects:bixby

if [[ -d /mnt/pkg/ ]]; then
  cp -fa pkg/* /mnt/pkg/
fi

# cleanup
unset ROOT

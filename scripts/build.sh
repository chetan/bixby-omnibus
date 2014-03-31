#!/usr/bin/env bash

# run's the actual build and creates a package via fpm.
#
# this should be run inside a vm on the target platform.
# normally called from bootstrap.sh

export ROOT=$(readlink -f $(dirname $0)/..)
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

if [ "$CLEAN" == "1" ]; then
  # nuke src/build - faster than waiting for omnibus clean
  rm -rf /var/cache/omnibus/src /var/cache/omnibus/build /opt/bixby
  bundle exec omnibus clean bixby
fi

bundle exec omnibus build project bixby

if [[ -d /mnt/pkg/ ]]; then
  cp -fa pkg/* /mnt/pkg/
fi

# cleanup
unset ROOT

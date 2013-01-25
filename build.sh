#!/usr/bin/env bash

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

if [[ -d $HOME/pkg/ ]]; then
  cp -fa pkg/* $HOME/pkg/
fi

# cleanup
unset ROOT

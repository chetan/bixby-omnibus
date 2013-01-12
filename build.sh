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

rake projects:bixby

# cleanup
unset ROOT

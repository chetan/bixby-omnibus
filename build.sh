#!/usr/bin/env bash

export ROOT=$(dirname $(readlink -f $0))
cd $ROOT
mkdir -p tmp
cd tmp

if [[ -d bixby-agent ]]; then
  cd bixby-agent
  git pull
else
  git clone https://github.com/chetan/bixby-agent.git
fi
cd $ROOT

rake project:bixby

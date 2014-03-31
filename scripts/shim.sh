#!/bin/bash -e

if [ ! -f go.sh ]; then
  echo "\wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh -O - | /bin/bash 2>&1 | tee $HOME/bixby-omnibus.log" > go.sh
fi

nohup /bin/bash go.sh >/dev/null 2>nohup.err </dev/null &

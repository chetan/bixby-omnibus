#!/bin/bash -e

run_build() {
  \wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh -O - | /bin/bash 2>&1 | tee $HOME/bixby-omnibus.log
}

nohup run_build >/dev/null 2>nohup.err </dev/null &
